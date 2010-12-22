from django.shortcuts import render_to_response
from django.template import RequestContext, TemplateDoesNotExist
from django.http import Http404
from django.contrib.markup.templatetags.markup import markdown
from typogrify.templatetags.typogrify import typogrify
from osubus_extra.models import Screenshot, Bulletin, VersionBulletin, CacheDatabase
import datetime

# FIXME more appropriate root-url discovery
DATABASE_ROOT_URL = "http://osubus.gamma-level.com"

def screenshots(request):
    all_shots = Screenshot.objects.all()
    return render_to_response('screenshots.html', {'screenshots' : all_shots}, context_instance=RequestContext(request))

def bulletins(request, api_version="v1"):
    bulletins = Bulletin.objects.all()
    try:
        version_bulletin = VersionBulletin.objects.all()[0]
    except IndexError:
        version_bulletin = None
    
    all_bulletins = []
    
    client_version = request.GET.get('version', None)
    if version_bulletin and client_version:
        try:
            client_version = map(int, client_version.split('.', 2))
            if len(client_version) < 3:
                client_version += [0,] * (3 - len(client_version))
            
            cl = client_version
            nw = (version_bulletin.major, version_bulletin.minor, version_bulletin.revision)
            
            if (nw[0] > cl[0]) or (nw[0] == cl[0] and nw[1] > cl[1]) or (nw[0] == cl[0] and nw[1] == cl[1] and nw[2] > cl[2]):
                all_bulletins.append(version_bulletin)
        except ValueError:
            pass
    
    all_bulletins += bulletins
    
    # last of the markdown'd bulletins has been added
    for i in all_bulletins:
        i.body = typogrify(markdown(i.body))
    
    dbversion = request.GET.get('dbversion', None)
    if dbversion:
        try:
            dbversion = int(dbversion)
        except ValueError:
            dbversion = None
    dbdate = request.GET.get('dbdate', None)
    if dbdate:
        try:
            dbdate = map(int, dbdate.split('/', 2))
            if not len(dbdate) == 3:
                raise ValueError
            # MM/DD/YYYY
            dbdate = datetime.date(dbdate[2], dbdate[0], dbdate[1])
        except IndexError:
            dbdate = None
    
    print dbdate, dbversion
    
    if dbversion and dbdate:
        try:
            db = CacheDatabase.objects.filter(version=dbversion)[0]
            print db.date
            if db.date > dbdate:
                # we have a new database to download
                dbbulletin = Bulletin(priority=2, title="!!!DBUPDATE", body=DATABASE_ROOT_URL + db.file.url)
                all_bulletins.append(dbbulletin)
        except IndexError:
            pass
    
    try:
        return render_to_response('bulletins.%s.xml' % (api_version,), {'bulletins' : all_bulletins}, mimetype='text/xml', context_instance=RequestContext(request))
    except TemplateDoesNotExist:
        raise Http404
