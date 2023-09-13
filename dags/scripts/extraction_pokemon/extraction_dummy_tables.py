TABLES = [
    {
        "name" : "berry",
        "url" : "berry/",
        "offset" : False,
        "selected_fields" : []
    },
    {
        "name" : "pokemon",
        "url" : "pokemon/?offset={}&limit={}",
        "offset" : True,
        "selected_fields" : ['id', 'name', 'base_experience', 'height', 'abilities', 'forms', 'game_indices', 'types', 'stats']
    }
]