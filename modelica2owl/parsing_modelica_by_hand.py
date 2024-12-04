def remove_all_inside_function(body: str, function_word: str):
    """Remove annotations in a hopefully fast way"""
    word_length = len(function_word)
    check_from = 0
    while True:
        start_index = body.find(function_word, check_from)
        if start_index == -1: break
        count = 0
        traveled = 0
        for c in body[start_index+word_length:]:
            traveled += 1
            match c:
                case "(": count += 1
                case ")": count -= 1
            if count == 0: break
        body = body[:start_index+word_length+1]+body[start_index+word_length+traveled-1:]#+1:] # +1 for the semicolon!
        check_from = start_index+word_length+2
    return body

def clean_modelica_code(code: str) -> str:
    # return code 
    return remove_all_inside_function(code, "annotation")
