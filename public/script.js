window.onload = function () {
    const isDev = window.location.hostname === 'localhost'
    const isProd = window.location.hostname === 'schema-viz.netlify.app'
    const isAdmin = JSON.parse(localStorage.getItem('is-admin'))
    const shouldTrack = isProd && !isAdmin
    const analytics = initAnalytics(shouldTrack)
    const errorTracking = initErrorTracking(shouldTrack)
    const app = Elm.Main.init()


    /* Elm ports */

    function sendToElm(msg) {
        // console.log('js message', msg)
        app.ports.jsToElm.send(msg)
    }
    app.ports && app.ports.elmToJs.subscribe(msg => {
        // setTimeout: a ugly hack to wait for Elm to render the model changes before running the commands :(
        setTimeout(() => {
            // console.log('elm message', msg)
            switch (msg.kind) {
                case 'Click':         click(msg.id); break;
                case 'ShowModal':     showModal(msg.id); break;
                case 'HideModal':     hideModal(msg.id); break;
                case 'HideOffcanvas': hideOffcanvas(msg.id); break;
                case 'ActivateTooltipsAndPopovers': activateTooltipsAndPopovers(); break;
                case 'ShowToast':     showToast(msg.toast); break;
                case 'LoadSchemas':   loadSchemas(); break;
                case 'SaveSchema':    saveSchema(msg.schema); break;
                case 'DropSchema':    dropSchema(msg.schema); break;
                case 'ReadFile':      readFile(msg.file); break;
                case 'ObserveSizes':  observeSizes(msg.ids); break;
                case 'ListenKeys':    listenHotkeys(msg.keys); break;
                case 'TrackPage':     analytics.then(a => a.trackPage(msg.name)); break;
                case 'TrackEvent':    analytics.then(a => a.trackEvent(msg.name, msg.details)); break;
                case 'TrackError':    analytics.then(a => a.trackError(msg.name, msg.details)); errorTracking.then(e => e.track(msg.name, msg.details)); break;
                default: console.error('Unsupported Elm message', msg); break;
            }
        }, 100)
    })

    function click(id) {
        getElementById(id).click()
    }
    function showModal(id) {
        bootstrap.Modal.getOrCreateInstance(getElementById(id)).show()
    }
    function hideModal(id) {
        bootstrap.Modal.getOrCreateInstance(getElementById(id)).hide()
    }
    function hideOffcanvas(id) {
        bootstrap.Offcanvas.getOrCreateInstance(getElementById(id)).hide()
    }
    function activateTooltipsAndPopovers() {
        document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(e => bootstrap.Tooltip.getOrCreateInstance(e))
        document.querySelectorAll('[data-bs-toggle="popover"]').forEach(e => bootstrap.Popover.getOrCreateInstance(e))
    }

    let toastCpt = 0
    function showToast(toast) {
        const toastContainer = document.getElementById('toast-container')
        if (toastContainer) {
            const toastNo = toastCpt += 1
            const toastId = 'toast-' + toastNo
            let bgColor = ''
            let btnColor = ''
            let autoHide = true
            switch (toast.kind) {
                case 'info':
                    break
                case 'warning':
                    bgColor = 'bg-warning'
                    break
                case 'error':
                    bgColor = 'bg-danger text-white'
                    btnColor = 'btn-close-white'
                    autoHide = false
                    break
                default:
                    break
            }
            let html =
                '<div class="toast align-items-center ' + bgColor + '" id="' + toastId + '" role="status" aria-live="polite" aria-atomic="true"' + (autoHide ? '' : ' data-bs-autohide="false"') + '>\n' +
                '  <div class="d-flex">\n' +
                '    <div class="toast-body">\n' +
                '      ' + toast.message + '\n' +
                '    </div>\n' +
                '    <button type="button" class="btn-close ' + btnColor + ' me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>\n' +
                '  </div>\n' +
                '</div>'
            toastContainer.insertAdjacentHTML('beforeend', html)
            bootstrap.Toast.getOrCreateInstance(getElementById(toastId)).show()
        } else {
            console.warn("Can't show toast, container not present", toast)
        }
    }

    const schemaPrefix = 'schema-'
    function loadSchemas() {
        const values = Object.keys(localStorage)
            .filter(key => key.startsWith(schemaPrefix))
            .map(key => [key.replace(schemaPrefix, ''), JSON.parse(localStorage.getItem(key))])
        sendToElm({kind: 'SchemasLoaded', schemas: values})
    }
    function saveSchema(schema) {
        const key = schemaPrefix + schema.id
        // setting dates should be done in Elm but can't find how to run a Task before calling a Port
        const now = Date.now()
        schema.info.updated = now
        if (localStorage.getItem(key) == null) { schema.info.created = now }
        try {
            localStorage.setItem(key, JSON.stringify(schema))
        } catch (e) {
            if (e.code === DOMException.QUOTA_EXCEEDED_ERR) {
                showToast({kind: 'error', message: "Can't save schema, storage quota exceeded. Use a smaller schema or clean unused ones."})
            } else {
                showToast({kind: 'error', message: "Can't save schema: " + e.message})
            }
            const name = 'local-storage'
            const details = {error: e.name, message: e.message}
            analytics.then(a => a.trackError(name, details)); errorTracking.then(e => e.track(name, details));
        }
    }
    function dropSchema(schema) {
        localStorage.removeItem(schemaPrefix + schema.id)
    }

    function readFile(file) {
        const reader = new FileReader()
        reader.onload = e => sendToElm({kind: 'FileRead', now: Date.now(), file: file, content: e.target.result})
        reader.readAsText(file)
    }

    const resizeObserver = new ResizeObserver(entries => {
        const sizes = entries.map(entry => ({
            id: entry.target.id,
            size: {
                width: entry.contentRect.width,
                height: entry.contentRect.height
            }
        }))
        sendToElm({kind: 'SizesChanged', sizes: sizes})
    })
    function observeSizes(ids) {
        ids.forEach(id => resizeObserver.observe(getElementById(id)))
    }

    const hotkeys = {}
    document.addEventListener('keydown', e => {
        Object.entries(hotkeys).forEach(([id, alternatives]) => {
            alternatives.forEach(hotkey => {
                if ((!hotkey.key || hotkey.key === e.key) &&
                    (!hotkey.ctrl || e.ctrlKey) &&
                    (!hotkey.shift || e.shiftKey) &&
                    (!hotkey.alt || e.altKey) &&
                    (!hotkey.meta || e.metaKey) &&
                    ((!hotkey.target && (!hotkey.oninput || e.target.localName !== 'input')) || (hotkey.target &&
                        (!hotkey.target.id || hotkey.target.id === e.target.id) &&
                        (!hotkey.target.class || e.target.className.split(' ').includes(hotkey.target.class)) &&
                        (!hotkey.target.tag || hotkey.target.tag === e.target.localName)))) {
                    if (hotkey.preventDefault) {
                        e.preventDefault()
                    }
                    sendToElm({kind: 'HotkeyUsed', id: id})
                }
            })
        })
    })
    function listenHotkeys(keys) {
        Object.assign(hotkeys, keys)
    }


    /* Bootstrap helpers */

    // hide tooltip on click (avoid orphan tooltips when element is removed)
    // cf https://getbootstrap.com/docs/5.0/components/tooltips/: "Tooltips must be hidden before their corresponding elements have been removed from the DOM."
    let currentTooltip = null
    window.addEventListener('show.bs.tooltip', e => {
        currentTooltip = e.target
    })
    window.addEventListener('click', () => {
        currentTooltip && bootstrap.Tooltip.getOrCreateInstance(currentTooltip).hide()
    })
    // autofocus element in modal that require it (not done automatically)
    // cd https://getbootstrap.com/docs/5.0/components/modal/: "Due to how HTML5 defines its semantics, the autofocus HTML attribute has no effect in Bootstrap modals."
    window.addEventListener('shown.bs.modal', e => {
        const input = e.target.querySelector('[autofocus]')
        input && input.focus()
        activateTooltipsAndPopovers()
    })
    window.addEventListener('hidden.bs.toast', e => {
        const toast = getElementById(e.target.id)
        toast.parentNode.removeChild(toast)
    })


    /* Autocomplete hacks, this is more than ugly and also very fragile, should find better ways to handle autocomplete!!! */

    // when the search is focused, the dropdown should be open:
    //  - prevent closing it if search input is still active
    //  - open it when search input is focused
    //  - close it when search input is blurred
    window.addEventListener('hide.bs.dropdown', e => {
        if(e.target.id === 'search' && e.target === document.activeElement) {
            e.preventDefault()
        }
    })
    window.addEventListener('focusin', e => {
        if (e.target.id === 'search') { setTimeout(() => bootstrap.Dropdown.getOrCreateInstance(e.target).show(), 10) }
    })
    window.addEventListener('focusout', e => {
        if (e.target.id === 'search') { setTimeout(() => bootstrap.Dropdown.getOrCreateInstance(e.target).hide(), 10) }
    })
    // search input parent is the dropdown element, on mousedown it's blurred but we want that only on click
    window.addEventListener('mousedown', e => {
        const dropdown = e.path.find(e => e.className === 'dropdown')
        const search = Array.from(dropdown?.children || []).find(e => e.id === 'search')
        if (search) {
            setTimeout(() => search.focus(), 10)
        }
    })
    // the second node inside the dropdown element is the dropdown menu, we want to blur the search on click
    window.addEventListener('click', e => {
        const dropdown = e.path.find(e => e.className === 'dropdown')
        const search = Array.from(dropdown?.children || []).find(e => e.id === 'search')
        if (search && e.path.find(e => e.className && e.className.includes('dropdown-menu'))) {
            search.blur()
        }
    })
    // blur search when esc key is pressed, doesn't work :(
    window.addEventListener('keydown', e => {
        const dropdown = e.path.find(e => e.className === 'dropdown')
        const search = Array.from(dropdown?.children || []).find(e => e.id === 'search')
        if (search && e.keyCode === 27) {
            search.blur()
        }
    })
    // do not submit search form on enter
    window.addEventListener('submit', e => {
        if (e.target[0].id === 'search') {
            e.preventDefault()
        }
    })


    /* Libs */

    function getElementById(id) {
        const elem = document.getElementById(id)
        if (elem) {
            return elem
        } else {
            throw new Error(`Can't find element with id '${id}'`)
        }
    }

    function maybeElementById(id) {
        const elem = document.getElementById(id)
        return elem ? [elem] : []
    }

    function loadScript(url) {
        return new Promise((resolve, reject) => {
            const script = document.createElement('script')
            script.src = url
            script.type='text/javascript'
            script.addEventListener('load', resolve)
            document.getElementsByTagName('head')[0].appendChild(script)
        })
    }

    function initAnalytics(shouldTrack) {
        if (shouldTrack) {
            // see https://getinsights.io/projects/TelOpGhJG0jZQtCk
            return loadScript('/assets/insights.js').then(() => {
                insights.init('TelOpGhJG0jZQtCk')
                insights.trackPages({hash: true, search: true})
                return {
                    trackPage: name => {
                        insights.track({
                            id: 'page-view',
                            parameters: {
                                name,
                                path: insights.parameters.path().value,
                                locale: insights.parameters.locale().value,
                                screenType: insights.parameters.screenType().value,
                                referrer: insights.parameters.referrer().value,
                            }
                        })
                    },
                    trackEvent: (name, details) => {
                        insights.track({
                            id: name,
                            parameters: {
                                ...details,
                                locale: insights.parameters.locale().value,
                                screenType: insights.parameters.screenType().value,
                                referrer: insights.parameters.referrer().value,
                            }
                        })
                    },
                    trackError: (name, details) => {
                        insights.track({
                            id: name + '-error',
                            parameters: {
                                ...details,
                                locale: insights.parameters.locale().value,
                                screenType: insights.parameters.screenType().value,
                                referrer: insights.parameters.referrer().value,
                            }
                        })
                    }
                }
            })
        } else {
            return Promise.resolve({
                trackPage: name => console.log('analytics.trackPage', name),
                trackEvent: (name, details) => console.log('analytics.trackEvent', name, details),
                trackError: (name, details) => console.log('analytics.trackError', name, details)
            })
        }
    }

    function initErrorTracking(shouldTrack) {
        if (shouldTrack) {
            return loadScript('https://js.sentry-cdn.com/268b122ecafb4f20b6316b87246e509c.min.js').then(() => {
                return {
                    track: (name, details) => Sentry.captureException(new Error(JSON.stringify({name, ...details})))
                }
            })
        } else {
            return Promise.resolve({
                track: (name, details) => console.log('error.track', name, details)
            })
        }
    }
}
