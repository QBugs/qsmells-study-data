import os, csv
from ast_parser_module import *
from find_smell_211_module import find_smell_211
from parse_circuit_bit_info_module import *
from helper import *
from find_smell_212_module import find_smell_212
from find_smell_221_module import find_smell_221
from find_smell_231_module import find_smell_231
from find_smell_232_module import find_smell_232
from build_function_is_list_return_dict_module import build_function_is_list_return_dict, build_is_list_var_list


def parse_file(file_dir):
    my_parsed_object = MyAstParser(file_dir)
    my_parsed_object.parse_file()
    return my_parsed_object


def parse_circuit_bit_info(my_parsed_object):
    my_circuit_bit_object = MyCircuitBitParser(my_parsed_object)
    my_circuit_bit_object.parse_file()
    return my_circuit_bit_object


def main():
    root_dir = '/Users/qihongchen/Desktop/quantum_smell_project/inputs/'
    result_csv_dir = '/Users/qihongchen/Desktop/quantum_smell_project/result.csv'
    with open(result_csv_dir, 'w+') as f:
        writer = csv.writer(f)
        writer.writerow(["file_dir", '211_result', "212_result", "221_result", "231_result", "232_result"])
        for file_name in os.listdir(root_dir):
            if not file_name.endswith(".py") or file_name != 'x.py':
                continue
            file_dir = root_dir + file_name
            file_dir = "/Users/qihongchen/Desktop/quantum_smell_project/inputs/x.py"
            print('file dir = ', file_dir)
            my_parsed_object = parse_file(file_dir)
            my_circuit_bit_object = parse_circuit_bit_info(my_parsed_object)
            function_is_list_return_dict = build_function_is_list_return_dict(my_parsed_object)
            is_list_var_list = build_is_list_var_list(function_is_list_return_dict, my_parsed_object)
            print("is_list_var_list = ", is_list_var_list)
            call_order_line_list = build_call_order_line_list(my_parsed_object, my_circuit_bit_object)
            smell_211_result = find_smell_211(my_parsed_object, my_circuit_bit_object, call_order_line_list)
            smell_212_result = find_smell_212(my_parsed_object, my_circuit_bit_object, call_order_line_list)
            smell_221_result = find_smell_221(my_parsed_object, call_order_line_list)
            smell_231_result = find_smell_231(my_parsed_object, call_order_line_list)
            smell_232_result = find_smell_232(my_parsed_object, my_circuit_bit_object, call_order_line_list)
            writer.writerow([file_dir, str(smell_211_result), str(smell_212_result), smell_221_result, str(smell_231_result), smell_232_result])


if __name__ == '__main__':
    main()