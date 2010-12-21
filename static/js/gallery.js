/* simple gallery */

/* special tag ids -- "gallery", "gallery-text", "gallery-title", "gallery-image" all divs */
/* and "gallery-list" the ul */

/* get the plaintext from an element */
function getElementText(el)
{
    var text = "";
    for (j in el.childNodes)
    {
        if (el.childNodes[j].nodeType == 3)
        {
            text += el.childNodes[j].data;
        } else if (el.childNodes[j].nodeType == 1) {
            text += getElementText(el.childNodes[j]);
        }
    }
    return text;
}

var preloadedImages = new Array();

function initGallery()
{
    if (!document.getElementById)
        return;
    
    if (!document.getElementById('gallery'))
        return;
    
    if (!document.getElementById('gallery-list'))
        return;
    
    document.getElementById('gallery').style.display = 'block';
    
    /* convert links from title - desc format */
    var listitems = document.getElementById('gallery-list').children;
    for (i in listitems)
    {
        if (!(listitems[i].children && listitems[i].children.length > 0))
            continue;
        
        var pic = listitems[i].children[0];
        var text = getElementText(listitems[i]);
        var splitarr = text.split(' - ', 2);
        
        var inner = "";
        var title = "";
        
        if (splitarr.length == 1)
        {
            inner = text;
        } else {
            inner = splitarr[0];
            title = splitarr[1];
        }
        
        /* preload */
        preloadedImages[i] = new Image();
        preloadedImages[i].src = pic.href;
        
        listitems[i].innerHTML = '<a href="' + pic.href + '" title="' + title + '">' + inner + '</a>';
    }
    
    /* now we hide the list */
    document.getElementById('gallery-list').style.display = 'none';
    
    var first = listitems[0]
    gallery(first);
}

var currentPic = false;

function gallery(pic)
{
    if (!document.getElementById)
        return true;
    
    piclink = pic.children[0];
    document.getElementById('gallery-text').innerHTML = piclink.title;
    document.getElementById('gallery-image').innerHTML = '<img src="' + piclink.href + '" />';
    document.getElementById('gallery-title').innerHTML = piclink.innerHTML;
    currentPic = pic;
    
    return false;
}

function galleryNext()
{
    if (currentPic)
    {
        var next = currentPic;
        do
        {
            next = next.nextSibling;
        } while (next && next.nodeType != 1);
        
        if (!next)
        {
            next = currentPic.parentNode.children[0];
        }
        gallery(next);
    }
    return false;
}

function galleryPrev()
{
    if (currentPic)
    {
        var prev = currentPic;
        do
        {
            prev = prev.previousSibling;
        } while (prev && prev.nodeType != 1);
        
        if (!prev)
        {
            prev = currentPic.parentNode.children[currentPic.parentNode.children.length - 1];
        }
        gallery(prev);
    }
    return false;
}

