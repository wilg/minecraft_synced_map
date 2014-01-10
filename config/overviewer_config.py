import os

worlds["world"] = os.environ['WORLD_DIR']

renders["overworld_day"] = {
    "world": "world",
    "title": "Overworld",
    "rendermode": smooth_lighting,
    "dimension": "overworld",
    "northdirection" : "upper-right",
    "optimizeimg" : 1
}

renders["overworld_night"] = {
    "world": "world",
    "title": "Overworld Night",
    "rendermode": smooth_night,
    "dimension": "overworld",
    "northdirection" : "upper-right",
    "optimizeimg" : 1
}

renders["nether"] = {
    "world": "world",
    "title": "Nether",
    "rendermode": nether,
    "dimension": "nether",
    "northdirection" : "upper-right",
    "optimizeimg" : 1
}

outputdir = os.environ['MAP_DIR']