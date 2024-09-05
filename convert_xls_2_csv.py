#!/usr/bin/python3

import os
import subprocess
import xlrd2
import csv

# színkódok
RED = '\033[0;31m'
GRE = '\033[0;32m'
YEL = '\033[1;33m'
LBL = '\033[1;34m'
LG = '\033[1;32m'
NC = '\033[0m'

# belépés a ticketek mappába
os.chdir("/home/kafka/kafka-admin-tool/ticketek/")
subprocess.call("ls -lah && pwd", shell=True)

xls_file = input("Kérlek válaszd ki a(z) .xls fájlodat: ")

print(f"{YEL}Kérlek válaszd ki a feldolgozandó munkafüzetet:{NC}")
print("1. Tömeges ACL igénylés")
print("2. Tömeges Topic igénylés")
option = input("Add meg a választott opció számát (1 vagy 2): ")

if option == '1':
    sheet_name = "Tömeges ACL igénylés"
elif option == '2':
    sheet_name = "Tömeges Topic igénylés"
else:
    print(f"{RED}Érvénytelen opció. Kérlek futtasd újra a scriptet és válassz 1 vagy 2 közül.{NC}")
    exit()

with xlrd2.open_workbook(xls_file) as wb:
    sh = wb.sheet_by_name(sheet_name)
    if sheet_name == "Tömeges ACL igénylés":
        #csv_file_name = f"{os.path.splitext(xls_file)[0]}_{sheet_name}.csv"
        csv_file_name = f"{os.path.splitext(xls_file)[0]}_" + "ACL.csv"
    else:
        csv_file_name = f"{os.path.splitext(xls_file)[0]}_" + "Topic.csv"
    with open(csv_file_name, 'w', newline='') as f:
        c = csv.writer(f, delimiter=';')
        for r in range(sh.nrows):
            c.writerow(sh.row_values(r))

print(f"A(z) {LG}{csv_file_name}{NC} fájl sikeresen létrehozva.")
print(f"A munkafüzet neve: {LG}{sheet_name}{NC}")