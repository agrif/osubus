from django.shortcuts import render_to_response
from django.template import RequestContext, TemplateDoesNotExist
from django.http import Http404
from osubus_extra.models import Screenshot, Bulletin, VersionBulletin

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
                all_bulletins += [version_bulletin,]
        except ValueError:
            pass
    
    all_bulletins += bulletins
    
    try:
        return render_to_response('bulletins.%s.xml' % (api_version,), {'bulletins' : all_bulletins}, mimetype='text/xml', context_instance=RequestContext(request))
    except TemplateDoesNotExist:
        raise Http404
