import subprocess
from rpy2.robjects import r
from rpy2.robjects.packages import importr, PackageNotInstalledError
from rpy2.robjects import globalenv
import rpy2.robjects as rpackages

def ensure_packages(pkg):
    try:
        importr(pkg) 
    except PackageNotInstalledError:
        print(f"Installing R package: {pkg}")
        r(f'install.packages("{pkg}")')
        return importr(pkg)
    
def dependencies():
    attached = r('gsub("^package:", "", grep("^package:", search(), value = TRUE))')
    attached_list = list(str(attached))
    for pkg in attached_list:
        ensure_packages(pkg)

def main():
    
    Date = "2025:05"
    r.source(Date + "/Incentives_Calculator.r")








    