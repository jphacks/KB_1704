def build_item_dict(items):
    res = {}
    for item in items:
        for (k,v) in item:
            res[k] = v
    return res


