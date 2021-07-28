window.onload = function () {
    const app = Elm.Main.init()


    /* Elm ports */

    function sendToElm(msg) {
        // console.log('js message', msg)
        app.ports.jsToElm.send(msg)
    }
    app.ports && app.ports.elmToJs.subscribe(msg => {
        // setTimeout: a ugly hack to wait for Elm to render the model changes before running the commands :(
        setTimeout(function () {
            // console.log('elm message', msg)
            switch (msg.kind) {
                case "Click":         click(msg.id); break;
                case "ShowModal":     showModal(msg.id); break;
                case "HideModal":     hideModal(msg.id); break;
                case "HideOffcanvas": hideOffcanvas(msg.id); break;
                case "ActivateTooltipsAndPopovers": activateTooltipsAndPopovers(); break;
                case "ShowToast":     showToast(msg.toast); break;
                case "LoadSchemas":   loadSchemas(); break;
                case "SaveSchema":    saveSchema(msg.schema); break;
                case "DropSchema":    dropSchema(msg.schema); break;
                case "ReadFile":      readFile(msg.file); break;
                case "ObserveSizes":  observeSizes(msg.ids); break;
                case "ListenKeys":    listenHotkeys(msg.keys); break;
                default: console.error('Unsupported Elm message', msg); break;
            }
        }, 100)
    })

    function click(id) {
        document.getElementById(id).click()
    }
    function showModal(id) {
        bootstrap.Modal.getOrCreateInstance(document.getElementById(id)).show()
    }
    function hideModal(id) {
        bootstrap.Modal.getOrCreateInstance(document.getElementById(id)).hide()
    }
    function hideOffcanvas(id) {
        bootstrap.Offcanvas.getOrCreateInstance(document.getElementById(id)).hide()
    }
    function activateTooltipsAndPopovers() {
        document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(e => bootstrap.Tooltip.getOrCreateInstance(e))
        document.querySelectorAll('[data-bs-toggle="popover"]').forEach(e => bootstrap.Popover.getOrCreateInstance(e))
    }

    let toastCpt = 0
    const toastContainer = document.getElementById('toast-container')
    function showToast(toast) {
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
        toastContainer.insertAdjacentHTML('beforeend', html);
        bootstrap.Toast.getOrCreateInstance(document.getElementById(toastId)).show()
    }

    const schemaPrefix = 'schema-'
    function loadSchemas() {
        const values = Object.keys(localStorage)
            .filter(key => key.startsWith(schemaPrefix))
            .map(key => [key.replace(schemaPrefix, ''), JSON.parse(localStorage.getItem(key))])
        sendToElm({kind: "SchemasLoaded", schemas: values})
    }
    function saveSchema(schema) {
        const key = schemaPrefix + schema.id
        // setting dates should be done in Elm but can't find how to run a Task before calling a Port
        const now = Date.now()
        schema.info.updated = now
        if (localStorage.getItem(key) == null) { schema.info.created = now }
        localStorage.setItem(key, JSON.stringify(schema))
    }
    function dropSchema(schema) {
        localStorage.removeItem(schemaPrefix + schema.id)
    }

    function readFile(file) {
        const reader = new FileReader()
        reader.onload = e => sendToElm({kind: "FileRead", now: Date.now(), file: file, content: e.target.result})
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
        sendToElm({kind: "SizesChanged", sizes: sizes})
    })
    function observeSizes(ids) {
        ids.forEach(id => {
            const el = document.getElementById(id)
            el ? resizeObserver.observe(el) : console.error("Can't observe element with '" + id + "' id, it doesn't exist")
        })
    }

    const hotkeys = {}
    document.addEventListener('keydown', function (e) {
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
                    sendToElm({kind: "HotkeyUsed", id: id})
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
    window.addEventListener('show.bs.tooltip', function (e) {
        currentTooltip = e.target
    })
    window.addEventListener('click', function () {
        currentTooltip && bootstrap.Tooltip.getOrCreateInstance(currentTooltip).hide()
    })
    // autofocus element in modal that require it (not done automatically)
    // cd https://getbootstrap.com/docs/5.0/components/modal/: "Due to how HTML5 defines its semantics, the autofocus HTML attribute has no effect in Bootstrap modals."
    window.addEventListener('shown.bs.modal', function (e) {
        const input = e.target.querySelector('[autofocus]')
        input && input.focus()
        activateTooltipsAndPopovers()
    })
    window.addEventListener('hidden.bs.toast', function (e) {
        const toast = document.getElementById(e.target.id)
        toast.parentNode.removeChild(toast)
    })


    /* Autocomplete hacks, this is more than ugly and also very fragile, should find better ways to handle autocomplete!!! */

    // when the search is focused, the dropdown should be open:
    //  - prevent closing it if search input is still active
    //  - open it when search input is focused
    //  - close it when search input is blurred
    const searchEl = document.getElementById('search')
    window.addEventListener('hide.bs.dropdown', function (e) {
        if(e.target.id === 'search' && searchEl === document.activeElement) {
            e.preventDefault()
        }
    })
    searchEl && searchEl.addEventListener('focus', function () {
        setTimeout(function() { bootstrap.Dropdown.getOrCreateInstance(searchEl).show() }, 10)
    })
    searchEl && searchEl.addEventListener('blur', function () {
        setTimeout(function() { bootstrap.Dropdown.getOrCreateInstance(searchEl).hide() }, 10)
    })
    // search input parent is the dropdown element, on mousedown it's blurred but we want that only on click
    searchEl && searchEl.parentElement.addEventListener('mousedown', function () {
        setTimeout(function () { searchEl.focus() }, 10)
    })
    // the second node inside the dropdown element is the dropdown menu, we want to blur the search on click
    searchEl && searchEl.parentElement.childNodes[1].addEventListener('click', function () {
        searchEl.blur()
    })
    // blur search when esc key is pressed
    searchEl && searchEl.addEventListener('keydown', function (e) {
        if (e.keyCode === 27) {
            searchEl.blur()
        }
    })
    // do not submit search form on enter
    searchEl && searchEl.parentElement.parentElement.addEventListener('submit', function(e) {
        e.preventDefault()
    })
}
