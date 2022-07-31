from collections import defaultdict
from base_util import *
from helper import *


def initialize_is_done_dict(function_name_list):
    result_dict = defaultdict(bool)
    for function_name in function_name_list:
        result_dict[function_name] = False
    return dict(result_dict)


def check_is_done(is_done_dict):
    values = list(is_done_dict.values())
    return all(values)


def check_function(function_implementation_line_list, function_is_list_return_dict, is_done_dict, function_implementation_dict):
    possible_return_type_list = list()
    current_scope_var_dict = defaultdict(bool)
    for function_line, function_line_number in function_implementation_line_list:
        left, right = get_left_right(function_line.strip())
        if left is None and 'return ' not in function_line:
            continue
        if 'return ' in function_line:
            if '[' in function_line or 'list(' in function_line:
                possible_return_type_list.append(True)
            return_var = function_line.split("return ")[1].strip()
            print("return var = ", return_var)
            if is_call_statement(return_var) and not is_loop(return_var):
                print("is call statement now")
                print('function_is_list_return_dict= ', function_is_list_return_dict)
                method_call_name, function_pure_name = analysis_call_statement(return_var)
                if function_pure_name not in function_implementation_dict:
                    continue
                if not is_done_dict[function_pure_name]:
                    return False, False
                else:
                    possible_return_type_list.append(function_is_list_return_dict[function_pure_name])
            else:
                if '[' in return_var:
                    return_var = return_var.split("[", 1)[0].strip()
                possible_return_type_list.append(current_scope_var_dict[return_var])
            continue
        if is_call_statement(right) and not is_loop(right):
            method_call_name, function_pure_name = analysis_call_statement(right)
            if function_pure_name not in function_implementation_dict:
                continue
            if not is_done_dict[function_pure_name]:
                return False, False
            else:
                is_list = function_is_list_return_dict[function_pure_name]
                current_scope_var_dict[left] = is_list
        elif not is_loop(right):
            if '[' in right or 'list(' in right:
                current_scope_var_dict[left] = True
            else:
                current_scope_var_dict[left] = False
    if any(possible_return_type_list):
        return True, True
    return True, False


def build_function_is_list_return_dict(my_parsed_object):
    function_implementation_dict = my_parsed_object.get_function_implementation_dict()
    function_name_list = list(function_implementation_dict.keys())
    is_done_dict = initialize_is_done_dict(function_name_list)
    function_is_list_return_dict = initialize_is_done_dict(function_name_list)
    while not check_is_done(is_done_dict):
        for function_name in function_implementation_dict:
            if is_done_dict[function_name]:
                continue
            is_function_finished, is_list_return = check_function(function_implementation_dict[function_name], function_is_list_return_dict, is_done_dict, function_implementation_dict)
            if is_function_finished:
                function_is_list_return_dict[function_name] = is_list_return
                is_done_dict[function_name] = True
    return function_is_list_return_dict


def build_is_list_var_list(function_is_list_return_dict, my_parsed_object):
    result_list = list()
    with open(my_parsed_object.get_file_dir(), 'r') as f:
        for line_num, line in enumerate(f):
            var, right_expr = get_left_right(line.strip())
            current_scope, current_scope_name = find_line_scope(line_num, my_parsed_object.get_line_info_dict())
            if (var is None and not is_call_statement(right_expr)) or line.strip().startswith("def ") or line.strip().startswith("class ") or is_loop(right_expr):
                continue
            if '[' in right_expr or 'list(' in right_expr:
                content = right_expr.split("[", 1)[1].strip().split("]", 1)[0].strip()
                content = content.replace('-', '')
                if content.isnumeric() or var is None:
                    continue
                result_list.append((line.strip(), line_num, current_scope, current_scope_name))
            if is_call_statement(right_expr) and '.' not in right_expr:
                call_pure_name = right_expr.split('(', 1)[0].strip()
                if call_pure_name not in my_parsed_object.get_function_implementation_dict():
                    continue
                if function_is_list_return_dict[call_pure_name] and var is not None:
                    result_list.append((line.strip(), line_num, current_scope, current_scope_name))
    return result_list



