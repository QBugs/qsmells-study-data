import ast
from collections import defaultdict
from helper import *
from base_util import *
from is_comment_module import is_comment


def is_valid_while_statement(current_loop_start_statement):
    ''' This function checks if the loop start statement is a valid while '''
    condition_operator_list = ['<', '>', '==']
    for condition_operator in condition_operator_list:
        if condition_operator in current_loop_start_statement:
           condition_operator_index = current_loop_start_statement.index(condition_operator)
           before_token, after_token = current_loop_start_statement.split()[condition_operator_index-1], current_loop_start_statement.split()[condition_operator_index+1]
           if before_token.isnumeric() or after_token.isnumeric():
              return True
    return False


def get_while_loop_times(current_loop_start_statement):
    condition_operator_list = ['<', '>', '==']
    for condition_operator in condition_operator_list:
        if condition_operator in current_loop_start_statement:
            condition_operator_index = current_loop_start_statement.index(condition_operator)
            before_token, after_token = current_loop_start_statement.split()[condition_operator_index-1], current_loop_start_statement.split()[condition_operator_index+1]
            if before_token.isnumeric() and after_token.isnumeric():
                return int(after_token) - int(before_token)
            elif before_token.isnumeric() and not after_token.isnumeric():
                return int(before_token)
            elif not before_token.isnumeric() and after_token.isnumeric():
                return int(after_token)


def handle_while_loop(file_dir, scope, name, call_order_line_list, current_count, depth_dict, function_implementation_dict, all_bit_collection_list, target_var_dict, bit_circuit_dict, converting_dict, variable_value_dict):
    all_loop_list = get_loops(file_dir)
    loop_statement_list = find_current_loop_str(all_loop_list, call_order_line_list, current_count)
    loop_len = len(loop_statement_list)
    current_loop_start_statement = call_order_line_list[current_count]
    if not is_valid_while_statement(current_loop_start_statement):
        return current_count + loop_len-1, depth_dict
    loop_times = get_while_loop_times(current_loop_start_statement)
    for loop_statement in loop_statement_list:
        if not is_call_statement(loop_statement):
            continue
        if 'for ' in loop_statement:
            current_count_temp, depth_dict = handle_for_loop(file_dir, scope, name, call_order_line_list, current_count, variable_value_dict, function_implementation_dict, all_bit_collection_list, target_var_dict, bit_circuit_dict, converting_dict, depth_dict)
        loop_statement_variable, loop_right_statement = get_left_right(loop_statement.strip())
        loop_statement_token_list = get_statement_token_list(loop_right_statement)
        loop_method_call_object_name, loop_function_call_pure_name = analysis_call_statement(loop_right_statement)
        if loop_function_call_pure_name in function_implementation_dict:
            continue
        loop_api_call_common_token_list = find_common_token_list(loop_statement_token_list, all_bit_collection_list, target_var_dict, bit_circuit_dict, scope, name, converting_dict)
        if len(loop_api_call_common_token_list) == 0:
            continue
        loop_api_call_common_token_bit_id_list = [i for i in range(loop_times)]
        depth_dict = update_depth_dict(loop_api_call_common_token_list, depth_dict, bit_circuit_dict, all_bit_collection_list, target_var_dict, scope, name, converting_dict, 'self_defined_bit_list', loop_api_call_common_token_bit_id_list)
    return current_count + loop_len-1, depth_dict


def get_loops(input_file_dir):
    file_content = read_file(input_file_dir)
    loop_list = list()
    loop_statements = ast.For, ast.AsyncFor

    nodes = ast.walk(ast.parse(file_content))
    for node in nodes:
        if isinstance(node, loop_statements):
            x = ast.get_source_segment(file_content, node)
            loop_list.append(x)
    return loop_list


def find_current_loop_str(all_loop_list, call_order_line_list, current_count):
    """ This function checks all for loop and find the current visiting one """
    for loop_str in all_loop_list:
        loop_str_list = loop_str.split('\n')
        for index, loop_line in enumerate(loop_str_list):
            statement_line = call_order_line_list[current_count + index][0].strip()
            if statement_line != loop_line.strip():
                break
        else:
            return loop_str, loop_str_list
    print("undefined loop str", call_order_line_list[current_count])
    exit(0)


def find_iteration_number(loop_statement):
    return loop_statement.split('range(', 1)[1].split(")", 1)[0].strip()


def get_for_loop_times(current_loop_start_statement, scope, name, variable_value_dict):
    iteration_variable_number = find_iteration_number(current_loop_start_statement)
    if ',' in iteration_variable_number:
        iteration_variable_number = iteration_variable_number.split(',')[1].strip()
    if iteration_variable_number.isnumeric():
        loop_times = int(iteration_variable_number)
    else:
        # 是变量
        loop_times = variable_value_dict[(iteration_variable_number, scope, name)]
        if loop_times == 0:
            loop_times = variable_value_dict[(iteration_variable_number, 'global', "None")]
    return loop_times


def handle_for_loop(file_dir, scope, name, call_order_line_list, current_count, variable_value_dict, function_implementation_dict, all_bit_collection_list, target_var_dict, bit_circuit_dict, converting_dict, depth_dict):
    all_loop_list = get_loops(file_dir)
    loop_statement_str, loop_statement_list = find_current_loop_str(all_loop_list, call_order_line_list, current_count)
    loop_len = len(loop_statement_list)
    print("deal with loop statement str = ", loop_statement_str)
    current_loop_start_statement = call_order_line_list[current_count][0].strip()
    if 'range(' not in current_loop_start_statement or 'len(' in current_loop_start_statement:
        return current_count + loop_len-1, depth_dict
    loop_times = get_for_loop_times(current_loop_start_statement, scope, name, variable_value_dict)
    print("loop times = ", loop_times)
    print("variable_value_dict = ", dict(variable_value_dict))
    for loop_statement in loop_statement_list:
        if not is_call_statement(loop_statement):
            continue
        print('in loop')
        loop_statement_variable, loop_right_statement = get_left_right(loop_statement.strip())
        loop_statement_token_list = get_statement_token_list(loop_right_statement)
        loop_method_call_object_name, loop_function_call_pure_name = analysis_call_statement(loop_right_statement)
        if loop_function_call_pure_name in function_implementation_dict:
            continue
        loop_api_call_common_token_list = find_common_token_list(loop_statement_token_list, all_bit_collection_list, target_var_dict, bit_circuit_dict, scope, name, converting_dict)
        if len(loop_api_call_common_token_list) == 0:
            continue
        loop_api_call_common_token_bit_id_list = [i for i in range(loop_times)]
        depth_dict = update_depth_dict(loop_api_call_common_token_list, depth_dict, bit_circuit_dict, all_bit_collection_list, target_var_dict,scope, name, converting_dict, 'self_defined_bit_list', loop_api_call_common_token_bit_id_list)
    return current_count + loop_len-1, depth_dict


def update_depth_dict(api_call_common_token_list, depth_dict, bit_circuit_dict, all_bit_collection_list, target_var_dict, scope, name, converting_dict, mode, bit_list):
    for api_call_common_token in api_call_common_token_list:
        api_call_common_token_pure_name, api_call_common_token_bit_id_list = get_token_bit_id_list(api_call_common_token, bit_circuit_dict, all_bit_collection_list, target_var_dict, scope, name, converting_dict)
        if mode != 'self_defined_bit_list':
            bit_list = api_call_common_token_bit_id_list
        for api_call_common_token_bit_id in bit_list:
            key_name = api_call_common_token_pure_name + '[' + str(api_call_common_token_bit_id) + ']'
            key = (key_name, scope, name)
            print("updating depth dict key = ", key)
            depth_dict[key] += 1
    return depth_dict


def build_common_target_argument_parameter_list(function_signature_parameter_list, cleaned_parameter_list, all_bit_collection_list, target_var_dict, scope, name):
    """ This function builds a list. It takes the parameter list and signature parameter list. Then, find ones that are target and update target var dict """
    result_list = list()
    for index, caller_parameter in enumerate(cleaned_parameter_list):
        if (caller_parameter, scope, name) in target_var_dict or caller_parameter in all_bit_collection_list:
            result_list.append(function_signature_parameter_list[index])
    return result_list


def find_value_info(converting_dict, token_pure_name, scope, name):
    for key in converting_dict:
        key_name, key_scope, key_scope_name = key
        value_name, value_scope, value_scope_name = converting_dict[key]
        if value_name == token_pure_name and scope == value_scope and name == value_scope_name:
            return key_name, key_scope, key_scope_name


def is_in_converting_dict(converting_dict, token_pure_name, scope, name):
    for key in converting_dict:
        value_name, value_scope, value_scope_name = converting_dict[key]
        if value_name == token_pure_name and scope == value_scope and name == value_scope_name:
            return True
    return False


def update_token_bit_list(token, bit_circuit_dict, target_var_dict):
    """This function takes a token who is a bit collection object and build token bit list i.e.fly, return [1,2,3,4] """
    size = find_bit_collection_size(token, bit_circuit_dict, target_var_dict)
    return [i for i in range(size)]


def find_bit_collection_size(target_bit_collection_name, bit_circuit_dict, target_var_dict):
    """ For a bit collection name i.e. fly. find it max size """
    for key in bit_circuit_dict:
        bit_collection_name, collection_size, scope, name = key
        if target_bit_collection_name == bit_collection_name:
            return collection_size
    # It is not a variable in bit_circuit_dict, but in target_var_dict
    for (variable, scope, name) in target_var_dict:
        corresponding_list = target_var_dict[variable]
        corresponding_pure_name = corresponding_list[0].split('[', 1)[0].strip()
        if corresponding_pure_name == target_bit_collection_name:
            return len(corresponding_list)


def build_token_bit_list(token, bit_circuit_dict, target_var_dict):
    """For a given token, i.e. a[1:5], returns [1,2,3,4]"""
    bit_id_list = list()
    b = token.split("[", 1)[1].strip().split(']', 1)[0].strip()
    if ':' in b and len(b) >= 3:
        start, end = b.split(':')
        start, end = int(start), int(end)
        bit_collection_name = token.split('[', 1)[0].strip()
        bit_collection_size = find_bit_collection_size(bit_collection_name, bit_circuit_dict, target_var_dict)
        if end < 0:
            end = bit_collection_size - abs(end)
        for i in range(start, end):
            bit_id_list.append(i)
    elif ':' in b and len(b) == 2:
        if b[0] != ':':
            start = int(b.split(':')[0].strip())
            bit_collection_name = token.split('[', 1)[0].strip()
            end = find_bit_collection_size(bit_collection_name, bit_circuit_dict, target_var_dict)
        else:
            start = 0
            bit_collection_name = token.split('[', 1)[0].strip()
            end = find_bit_collection_size(bit_collection_name, bit_circuit_dict, target_var_dict)
        if end < 0:
            bit_collection_size = find_bit_collection_size(bit_collection_name, bit_circuit_dict, target_var_dict)
            end = bit_collection_size - abs(end)
        for i in range(start, end):
            bit_id_list.append(i)
    elif len(b) == 1:
        bit_id_list = [b]
    result_bit_id_list = list()
    for bit_id in bit_id_list:
        if str(bit_id).isnumeric():
            result_bit_id_list.append(bit_id)
    return result_bit_id_list


def get_token_bit_id_list(token, bit_circuit_dict, all_bit_collection_list, target_var_dict, scope, name, converting_dict):
    """ For a given token, returns the method call object name, and the index, i.e. a[1:5] return a, [1,2,3,4]"""
    if token.startswith('['):
        token = token[1:]
    if '[' in token:
        token_pure_name = token.split('[', 1)[0].strip()
        token_bit_list = build_token_bit_list(token, bit_circuit_dict, target_var_dict)
    else:
        token_pure_name = token
        if token_pure_name in all_bit_collection_list:
            token_bit_list = update_token_bit_list(token, bit_circuit_dict, target_var_dict)
        elif (token_pure_name, scope, name) in target_var_dict:
            token_bit_list = list()
            for bit_id, bit_scope, bit_scope_name in target_var_dict[(token_pure_name, scope, name)]:
                key = bit_id.split("[", 1)[1].strip().split("]", 1)[0].strip()
                token_bit_list.append(key)
        elif is_in_converting_dict(converting_dict, token_pure_name, scope, name):
            value_converting_variable_name, value_converting_scope, value_converting_scope_name = find_value_info(converting_dict, token_pure_name, scope, name)
            token_bit_list = list()
        else:
            token_bit_list = list()
    return token_pure_name, token_bit_list


def is_in_depth_dict(key_object_name, depth_dict):
    for depth_key_object in depth_dict:
        depth_key_object_bit_name = depth_key_object[0]
        depth_key_object_bit_pure_name = depth_key_object_bit_name.split('[', 1)[0].strip()
        if depth_key_object_bit_pure_name == key_object_name:
            return True
    return False


def analysis_register_statement(line, file_line_list, line_count):
    statement = line.split('=', 1)[1].strip()
    parameters = statement.split('(', 1)[1][:-1].strip()
    left, right = get_left_right(line.strip())
    num_bits_variable_name = ""
    num_bits = ""
    for parameter in parameters.split(','):
        word_tokens = parameter.split('=')
        word_tokens = [x.strip() for x in word_tokens]
        if ('name=' in word_tokens) or ('name' in word_tokens):
            bit_name = parameter.split("=")[1].strip()
        else:
            num_bits_variable_name = parameter.strip()
    partial_content = file_line_list[:line_count]
    partial_content.reverse()
    for line_number in range(len(partial_content)):
        line = partial_content[line_number].strip()
        if is_comment(line, line_number + line_count - 1, file_line_list) or line == "" or line.startswith("##") or '=' not in line:
            continue
        variable, statement = line.split("=", 1)
        statement = statement.split('#')[0].strip()
        if variable.strip() == num_bits_variable_name and statement.strip().isdigit():
            num_bits = int(statement.strip())
    return num_bits, left


def build_width_dict(bit_circuit_dict):
    """ This function builds the width result by removing un-necessary terms in bit circuit dict """
    result_dict = defaultdict(int)
    for key in bit_circuit_dict:
        bit_collections_name, collection_size, scope, name = key
        result_dict[bit_collections_name] = collection_size
    return result_dict


def build_register_circuit_dict(file_dir, line_info_dict):
    with open(file_dir, 'r') as f:
        file_line_list = f.readlines()
    quantum_bit_collection = defaultdict(tuple)
    quantum_bit_name_collections = list()
    circuit_name_quantum_bit_collection = defaultdict(list)
    for line_count, line in enumerate(file_line_list, 0):
        line = line.strip()
        scope, name = find_line_scope(line_count, line_info_dict)
        if 'QuantumRegister' in line and 'import ' not in line:
            num_bits, bit_name = analysis_register_statement(line, file_line_list, line_count)
            quantum_bit_name_collections.append((bit_name, num_bits, scope, name))
        elif 'QuantumCircuit' in line and 'import ' not in line and '=' in line:
            circuit_name = line.split('=', 1)[0].strip()
            circuit_parameter_list = line.split('=')[1].strip().split('(', 1)[1][:-1].strip().split(',')
            circuit_parameter_list = [x.strip() for x in circuit_parameter_list]
            circuit_name_quantum_bit_collection[(circuit_name, line_count, scope, name)] = circuit_parameter_list
    for bit_name, num_bits, bit_scope, bit_scope_name in quantum_bit_name_collections:
        bit_name = bit_name.replace('"', "")
        bit_name = bit_name.replace("'", '')
        for circuit_name, line_count, circuit_scope, circuit_scope_name in circuit_name_quantum_bit_collection:
            initialized_bit_var_list = circuit_name_quantum_bit_collection[(circuit_name, line_count, circuit_scope, circuit_scope_name)]
            if bit_name in initialized_bit_var_list:
                quantum_bit_collection[(bit_name, num_bits, bit_scope, bit_scope_name)] = (circuit_name, line_count, circuit_scope, circuit_scope_name)
    return quantum_bit_collection


def update_depth_dict_var(depth_dict, converting_dict, statement_var_size_dict):
    """ This function takes depth dict and update it by adding variables that are copies of quantum collection object"""
    new_depth_dict = defaultdict(int)
    for key_object in converting_dict:
        value_object = converting_dict[key_object]
        if is_in_depth_dict(key_object[0], depth_dict) and not is_in_depth_dict(value_object[0], depth_dict):
            value_name, value_scope, value_name = value_object
            size = statement_var_size_dict[value_object]
            for i in range(size):
                key_name = value_object[0] + '[' + str(i) + ']'
                new_depth_dict[(key_name, value_scope, value_name)] = 0
    for key_object in depth_dict:
        new_depth_dict[key_object] = depth_dict[key_object]
    return new_depth_dict


def update_target_var_dict_call(function_signature_parameter_list, cleaned_caller_parameter_list, target_var_dict, all_bit_collection_list, statement, bit_circuit_dict, converting_dict, scope, name, function_call_pure_name):
    """ This function updates the target var dict """
    # 1st Case: parameter call and function signature argument list
    common_target_argument_parameter_list = build_common_target_argument_parameter_list(function_signature_parameter_list, cleaned_caller_parameter_list, all_bit_collection_list, target_var_dict, scope, name)
    if len(common_target_argument_parameter_list) == 0:
        return target_var_dict, converting_dict
    original_caller_parameter_list = statement.split('(', 1)[1].strip().split(")", 1)[0].strip().split(',')
    for index, original_caller_parameter in enumerate(original_caller_parameter_list):
        original_caller_parameter = original_caller_parameter.strip()
        original_caller_parameter_pure_name, original_caller_parameter_bit_id_list = get_token_bit_id_list(
            original_caller_parameter, bit_circuit_dict, all_bit_collection_list, target_var_dict, scope, name, converting_dict)
        try:
            corresponding_signature_parameter_name = function_signature_parameter_list[index]
        except IndexError:
            corresponding_signature_parameter_name = function_signature_parameter_list[-1]
        converting_dict[(original_caller_parameter_pure_name, scope, name)] = (corresponding_signature_parameter_name, 'function', function_call_pure_name)
        for original_caller_parameter_bit_id in original_caller_parameter_bit_id_list:
            key = original_caller_parameter_pure_name + '[' + str(original_caller_parameter_bit_id) + ']'
            target_var_dict[(corresponding_signature_parameter_name, 'function', function_call_pure_name)].append((key, 'function', function_call_pure_name))
    return target_var_dict, converting_dict


def initialize_depth_dict(bit_circuit_dict):
    """ This function initialize the depth dict, only include the trivial one"""
    depth_dict = defaultdict(int)
    for key in bit_circuit_dict:
        bit_collections_name, collection_size, scope, scope_name = key
        for count in range(collection_size):
            name = bit_collections_name + '[' + str(count) + ']'
            depth_dict[(name, scope, scope_name)] = 0
    return depth_dict


def build_statement_var_size_dict(bit_circuit_dict):
    result_dict = defaultdict(int)
    for var_name, size, scope, name in bit_circuit_dict:
        result_dict[(var_name, scope, name)] = size
    return result_dict


def get_statement_token_list(statement):
    """ This function takes a statement, return a list of tokens depending on the type of statement """
    # if it is a non call statement i.e. x = fly + 3
    # return [fly, 3]
    # if it is a call statement i.e. x = hello(fly, v)
    # return [fly, v]
    # if it is a mix like x = y + hello(fly, v)
    # return [y, fly, v]
    result_list = []
    if '(' not in statement:
        y = re.split(r"\]", statement)
        z = []
        for i in y:
            i = i.strip()
            if '[' in i:
                z.append(i + ']')
            else:
                z.append(i)
        for x in z:
            x = x.split('+', 1)[0].strip()
            x = x.split('-', 1)[0].strip()
            x = x.split('*', 1)[0].strip()
            x = x.split('/', 1)[0].strip()
            x = x.split('//', 1)[0].strip()
            x = x.split('**', 1)[0].strip()
            x = x.strip()
            if x == "":
                continue
            result_list.append(x)
    else:
        result_list = statement.split("(",1)[1].strip().split(")",1)[0].strip().split(',')
        result_list = list(filter(lambda x: (x.strip() != ""), result_list))
        result_list = list(map(lambda x: (x.strip()), result_list))

    return result_list


def clean_converting_dict(converting_dict):
    """ This function clean up the +-*/ in the converting dict"""
    result_dict = defaultdict(tuple)
    for key in converting_dict:
        var, scope, name = key
        var = var.split("+", 1)[0].strip()
        var = var.split("-", 1)[0].strip()
        var = var.split("*", 1)[0].strip()
        var = var.split("/", 1)[0].strip()
        var = var.split("//", 1)[0].strip()
        var = var.split("**", 1)[0].strip()
        var = var.split("[", 1)[0].strip()
        var = var.split("]", 1)[0].strip()
        result_dict[(var, scope, name)] = converting_dict[key]
    return result_dict


def find_common_token_list(statement_token_list, all_bit_collection_list, target_var_dict, bit_circuit_dict, scope, name, converting_dict):
    """ This function builds the list of tokens who are bit collection object """
    result_list = list()
    for token in statement_token_list:
        token = token.strip()
        token_pure_name, token_bit_id_list = get_token_bit_id_list(token, bit_circuit_dict, all_bit_collection_list, target_var_dict, scope, name, converting_dict)
        if token_pure_name in all_bit_collection_list or (token_pure_name, scope, name) in target_var_dict:
            result_list.append(token)
    return result_list


def get_cleaned_caller_parameter_list(statement):
    cleaned_parameter_list = statement.split("(", 1)[1].strip().split(")", 1)[0].strip().split(",")
    cleaned_parameter_list = list(filter(lambda x: (x.strip() != ""), cleaned_parameter_list))
    cleaned_parameter_list = list(map(lambda x: (x.strip()), cleaned_parameter_list))
    return cleaned_parameter_list


def get_function_signature_parameter_list(function_signature):
    function_signature_parameter_list = function_signature.split("(", 1)[1].split(")", 1)[0].strip().split(',')
    function_signature_parameter_list = list(filter(lambda x: (x.strip() != ''), function_signature_parameter_list))
    function_signature_parameter_list = list(map(lambda x: x.strip(), function_signature_parameter_list))
    return function_signature_parameter_list


def build_cleaned_regular_statement_token_list(regular_statement_token):
    cleaned_regular_statement_token_list = regular_statement_token.split()
    cleaned_regular_statement_token_list = list(
        filter(lambda x: (x.strip() != ""), cleaned_regular_statement_token_list))
    cleaned_regular_statement_token_list = list(map(lambda x: (x.strip()), cleaned_regular_statement_token_list))
    return cleaned_regular_statement_token_list


def update_statement_var_size_dict(variable, common_regular_statement_token_list, statement_var_size_dict, scope, name):
    size = -1
    for common_token in common_regular_statement_token_list:
        for statement_var, statement_scope, statement_name in statement_var_size_dict:
            if statement_scope == scope and statement_name == name and statement_var == common_token:
                size = statement_var_size_dict[(statement_var, statement_scope, statement_name)]
                break
        if size == -1:
            for statement_var, statement_scope, statement_name in statement_var_size_dict:
                if statement_var == common_token:
                    size = statement_var_size_dict[(statement_var, statement_scope, statement_name)]
                    break
        statement_var_size_dict[(variable, scope, name)] = size
    return statement_var_size_dict


def update_target_var_dict_statement(target_var_dict, common_regular_statement_token_list, bit_circuit_dict, all_bit_collection_list, variable, converting_dict, scope, name):
    for common_regular_statement_token_object in common_regular_statement_token_list:
        common_regular_statement_token_pure_name, common_regular_statement_token_bit_id_list = get_token_bit_id_list(common_regular_statement_token_object, bit_circuit_dict, all_bit_collection_list, target_var_dict, scope, name, converting_dict)
        if variable in all_bit_collection_list:
            continue
        for contained_bit_collection_bit_id in common_regular_statement_token_bit_id_list:
            converting_dict[(common_regular_statement_token_pure_name, scope, name)] = (variable, scope, name)
            key = common_regular_statement_token_pure_name + '[' + str(contained_bit_collection_bit_id) + ']'
            target_var_dict[(variable, scope, name)].append((key, scope, name))
    return target_var_dict, converting_dict


def build_depth_dict(bit_circuit_dict, all_bit_collection_list, my_parsed_object, call_order_line_list):
    input_file_dir = my_parsed_object.get_file_dir()
    function_implementation_dict = my_parsed_object.get_function_implementation_dict()
    line_info_dict = my_parsed_object.get_line_info_dict()
    depth_dict = initialize_depth_dict(bit_circuit_dict)
    converting_dict = defaultdict(str)
    target_var_dict = defaultdict(list)  # For any variable that not directly defined bit collection, such as a = fly[2]
    variable_value_dict = defaultdict(int)
    statement_var_size_dict = build_statement_var_size_dict(bit_circuit_dict)
    current_count = 0

    while current_count < len(call_order_line_list):
        line_statement, line_number = call_order_line_list[current_count]
        print("line statement = ", line_statement, " line number = ", line_number)
        variable, statement = get_left_right(line_statement.strip())
        statement_token_list = get_statement_token_list(statement)
        scope, name = find_line_scope(line_number, line_info_dict)
        converting_dict = clean_converting_dict(converting_dict)
        if is_call_statement(statement) and 'def ' not in statement and not is_loop(statement):
            # 纯call， api或者self defined
            method_call_object_name, function_call_pure_name = analysis_call_statement(statement)
            if function_call_pure_name not in function_implementation_dict:  # 纯api call
                api_call_common_token_list = find_common_token_list(statement_token_list, all_bit_collection_list, target_var_dict, bit_circuit_dict, scope, name, converting_dict)
                if len(api_call_common_token_list) == 0:
                    current_count += 1
                    continue
                depth_dict = update_depth_dict(api_call_common_token_list, depth_dict, bit_circuit_dict, all_bit_collection_list, target_var_dict, scope, name, converting_dict, 'non_self_defined', [])
                current_count += 1
            elif function_call_pure_name in function_implementation_dict:  # self defined
                cleaned_caller_parameter_list = get_cleaned_caller_parameter_list(statement)
                function_signature, function_start_line_number = function_implementation_dict[function_call_pure_name][0]
                function_signature_parameter_list = get_function_signature_parameter_list(function_signature)
                target_var_dict, converting_dict = update_target_var_dict_call(function_signature_parameter_list,cleaned_caller_parameter_list, target_var_dict, all_bit_collection_list, statement, bit_circuit_dict, converting_dict, scope, name, function_call_pure_name)
                current_count += 1
        else:  # 是普通statement包括for, while loop
            if (variable is None or 'def ' in line_statement) and not line_statement.startswith('for'):
                current_count += 1
                continue
            if is_loop(statement) and (statement.strip().startswith("for ") or statement.strip().startswith("while")):
                if 'for' in statement:
                    current_count, depth_dict = handle_for_loop(input_file_dir, scope, name, call_order_line_list, current_count, variable_value_dict, function_implementation_dict, all_bit_collection_list, target_var_dict, bit_circuit_dict, converting_dict, depth_dict)
                    print('return count = ', current_count)
                    print('return depth dict = ', dict(depth_dict))
                else:
                    current_count, depth_dict = handle_while_loop(input_file_dir, scope, name, call_order_line_list, current_count, depth_dict, function_implementation_dict, all_bit_collection_list, target_var_dict, bit_circuit_dict, converting_dict, variable_value_dict)
            else:
                if statement.isnumeric():
                    variable_value_dict[(variable, scope, name)] = int(statement)
                for regular_statement_token in statement_token_list:
                    cleaned_regular_statement_token_list = build_cleaned_regular_statement_token_list(regular_statement_token)
                    common_regular_statement_token_list = find_common_token_list(cleaned_regular_statement_token_list, all_bit_collection_list, target_var_dict, bit_circuit_dict, scope, name, converting_dict)
                    if len(common_regular_statement_token_list) == 0:
                        continue
                    statement_var_size_dict = update_statement_var_size_dict(variable, common_regular_statement_token_list, statement_var_size_dict, scope, name)
                    depth_dict = update_depth_dict(common_regular_statement_token_list, depth_dict, bit_circuit_dict, all_bit_collection_list, target_var_dict, scope, name, converting_dict, 'non_self_defined', [])
                    target_var_dict, converting_dict = update_target_var_dict_statement(target_var_dict, common_regular_statement_token_list, bit_circuit_dict, all_bit_collection_list, variable, converting_dict, scope, name)
            current_count += 1
    converting_dict = clean_converting_dict(converting_dict)
    depth_dict = update_depth_dict_var(depth_dict, converting_dict, statement_var_size_dict)
    return depth_dict


def find_smell_231(my_parsed_object, call_order_line_list):
    bit_circuit_dict = build_register_circuit_dict(my_parsed_object.get_file_dir(), my_parsed_object.get_line_info_dict())
    width_dict = build_width_dict(bit_circuit_dict)
    print("width dict = ", width_dict)
    all_bit_collection_list = list(width_dict.keys())
    depth_dict = build_depth_dict(bit_circuit_dict, all_bit_collection_list, my_parsed_object, call_order_line_list)
    for key in depth_dict:
        print("key = ", key, " val = ", depth_dict[key])
    return width_dict, depth_dict