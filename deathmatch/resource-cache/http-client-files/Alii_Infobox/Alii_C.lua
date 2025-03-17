local screen = {guiGetScreenSize()}
local browser = createBrowser(screen[1], screen[2], true, true)
local link = "http://mta/local/html/ui.html"

function browserRender()
    dxDrawImage(0, 0, screen[1], screen[2], browser, 0, 0, 0, tocolor(255, 255, 255, 255), true)
end

addEventHandler("onClientBrowserCreated", browser, function()
	loadBrowserURL(source, link)
    addEventHandler("onClientRender", root, browserRender)
end)

function add(title, type, message, time)
if not time then time = 5 end
    executeBrowserJavascript(browser, "window.postMessage( { action : 'open', title : '".. title .."', type : '".. type .."', message : '".. message .."', time : ".. time * 1370 .." }, '*' )")
end
addEvent("add", true)
addEventHandler("add", root, add)

addCommandHandler("testalii",function(cmd,code)
if code ~= "456456" then return end
add("خطا","error","vertual life",5)
add("اطلاعات","info","vertual life",5)
add("موفق","success","vertual life",5)
add("Money","money","Type Money Infobox",5)
add("Lock","lock","Type Lock Infobox",5)
add("Work","work","Type Work Infobox",5)
end)