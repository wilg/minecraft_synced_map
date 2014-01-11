import os

worlds["world"] = os.environ['WORLD_DIR']

def signFilter(poi):
    if poi['id'] == 'Sign':
        return "\n".join([poi['Text1'], poi['Text2'], poi['Text3'], poi['Text4']])

def playerIcons(poi):
    if poi['id'] == 'Player':
        poi['icon'] = "http://overviewer.org/avatar/%s" % poi['EntityId']
        return "Last known location for %s" % poi['EntityId']

def chestFilter(poi):
    if poi['id'] == "Chest":
        return ("Chest", "Chest with %d items" % len(poi['Items']))

markers = [
    dict(name="Signs", filterFunction=signFilter),
    dict(name="Players", filterFunction=playerIcons, checked=True)
    ]

renders["overworld_day"] = {
    "world": "world",
    "title": "Overworld",
    "rendermode": smooth_lighting,
    "dimension": "overworld",
    "northdirection" : "upper-right",
    'markers': markers,
    "optimizeimg" : 1
}

renders["overworld_reverse"] = {
    "world": "world",
    "title": "Overworld (reverse)",
    "rendermode": smooth_lighting,
    "dimension": "overworld",
    "northdirection" : "lower-left",
    'markers': markers,
    "optimizeimg" : 1
}

renders["nether"] = {
    "world": "world",
    "title": "Nether",
    "rendermode": nether_lighting,
    "dimension": "nether",
    "northdirection" : "upper-right",
    'markers': markers,
    "optimizeimg" : 1
}

outputdir = os.environ['MAP_DIR']