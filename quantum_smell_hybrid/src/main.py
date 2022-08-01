import csv
import os
from find_smell_211_module import find_smell_211
from find_smell_231_module import find_smell_231
from find_smell_232_module import find_smell_232
from find_smell_233_module import find_smell_233
from find_smell_234_module import find_smell_234


def main():
    csv_root_dir = "/Users/qihongchen/Desktop/quantum_smell_hybrid/inputs/"
    result_file_dir = "/Users/qihongchen/Desktop/quantum_smell_hybrid/result.csv"
    with open(result_file_dir, 'w+') as f:
        writer = csv.writer(f)
        writer.writerow(["file_dir", "smell211", "smell_231", "smell_232", "smell_233", "smell_234"])
        for csv_file_name in os.listdir(csv_root_dir):
            csv_file_dir = csv_root_dir + csv_file_name
            with open(csv_file_dir, 'r') as g:
                reader = list(csv.reader(g))
                title = reader[0][0]
                content = reader[1:]
                smell_211_result = find_smell_211(title)
                smell_231_result = find_smell_231(title, content)
                smell_232_result = find_smell_232(title)
                smell_233_result = find_smell_233(content)
                smell_234_result = find_smell_234(content)
                writer.writerow([csv_file_name, smell_211_result, smell_231_result, smell_232_result, smell_233_result, smell_234_result])


if __name__ == '__main__':
    main()