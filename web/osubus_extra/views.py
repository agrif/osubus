from django.shortcuts import render_to_response
from django.template import RequestContext, TemplateDoesNotExist
from django.http import Http404
from django.contrib.sites.models import Site
from django.contrib.markup.templatetags.markup import markdown
from django.contrib.auth.decorators import login_required
from typogrify.templatetags.typogrify import typogrify
from osubus_extra.models import Screenshot, Bulletin, VersionBulletin, CacheDatabase, VersionStats
import datetime

def screenshots(request):
    all_shots = Screenshot.objects.all()
    return render_to_response('screenshots.html', {'screenshots' : all_shots}, context_instance=RequestContext(request))

@login_required
def stats(request):
    colors = ['ff0000', '00ff00', '0000ff']
    # charts = [{'title' : "Chart Title",
    #            'dates' : range(32),
    #            'date_count' : 5,
    #            'range' : 3,
    #            'lines' : [{'legend' : 'data1',
    #                        'data' : range(32)},
    #                       {'legend' : 'data2',
    #                        'data' : [1, 0, 3, 2]},
    #                       ],
    #            }]
    charts = []
    
    now = datetime.datetime.now()
    spans = [('1 week', datetime.timedelta(7)),
             ('1 month', datetime.timedelta(30)),
             ('1 year', datetime.timedelta(365))]
    groups = [('by version', lambda s: "%s.%s.%s" % (s.major, s.minor, s.revision)),
              ('by dbdate', lambda s: str(s.dbdate)),
              ('by dbversion', lambda s: str(s.dbversion)),]
    for span in spans:
        stats = VersionStats.objects.filter(date__gte=now - span[1])
        dates = []
        groupings = []
        for i in range(len(groups)):
            groupings.append({})
        for stat in stats:
            datestr = str(stat.date)
            if not datestr in dates:
                dates.append(datestr)
            keys = map(lambda g: g[1](stat), groups)
            for i, key in enumerate(keys):
                if not key in groupings[i]:
                    groupings[i][key] = []
        
        for datei, date in enumerate(dates):
            for stat in stats:
                keys = map(lambda g: g[1](stat), groups)
                if not str(stat.date) == date:
                    continue
                for i, key in enumerate(keys):
                    while len(groupings[i][key]) <= datei:
                        groupings[i][key].append(0)
                    groupings[i][key][datei] += stat.count
        dates.reverse()
        for i, grouping in enumerate(groupings):
            name = groups[i][0]
            chart = {'title' : "%s (%s)" % (name, span[0]),
                     'dates' : dates,
                     'date_count' : 5,
                     'lines' : []}
            sorted_keys = grouping.keys()
            sorted_keys.sort()
            data_max = []
            for key in sorted_keys:
                data = grouping[key]
                data.reverse()
                chart['lines'].append({'legend' : key, 'data' : data})
                if data:
                    data_max.append(max(data))
            if data_max:
                chart['range'] = max(data_max)
            else:
                chart['range'] = 10
            charts.append(chart)
    
    for chart in charts:
        for i, l in enumerate(chart['lines']):
            l['color'] = colors[i % len(colors)]
        if len(chart['dates']) > 1:
            new_dates = []
            datei = 0.0
            while datei < len(chart['dates']):
                new_dates.append(chart['dates'][int(datei)])
                datei += (len(chart['dates']) - 1.0)/chart['date_count'];
            chart['dates'] = new_dates
    
    return render_to_response('stats.html', {'chartlist' : charts}, context_instance=RequestContext(request))

def bulletins(request, api_version="v1"):
    bulletins = Bulletin.objects.all()
    try:
        version_bulletin = VersionBulletin.objects.all()[0]
    except IndexError:
        version_bulletin = None
    
    all_bulletins = []
    
    client_version = request.GET.get('version', None)
    if client_version:
        try:
            client_version = map(int, client_version.split('.', 2))
            if len(client_version) < 3:
                client_version += [0,] * (3 - len(client_version))
            
            if version_bulletin:
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
    
    if dbversion and dbdate:
        try:
            db = CacheDatabase.objects.filter(version=dbversion)[0]
            if db.date > dbdate:
                # we have a new database to download
                DATABASE_ROOT_URL = "http://" + Site.objects.get_current().domain
                dbbulletin = Bulletin(priority=2, title="!!!DBUPDATE", body=DATABASE_ROOT_URL + db.file.url)
                all_bulletins.append(dbbulletin)
        except IndexError:
            pass
    
    if client_version and dbversion and dbdate:
        VersionStats.increment(client_version, dbversion, dbdate)
    
    try:
        return render_to_response('bulletins.%s.xml' % (api_version,), {'bulletins' : all_bulletins}, mimetype='text/xml', context_instance=RequestContext(request))
    except TemplateDoesNotExist:
        raise Http404
