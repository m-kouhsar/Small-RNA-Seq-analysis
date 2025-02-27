# -*- coding: utf-8 -*-
"""
Created on Mon Nov  8 09:20:34 2021

@author: m.kouhsar@exeter.ac.uk

Purifying hairpin and mature miRNAs fasta files by removing unwanten characters.
"""

######### input parameters ###################
CurWD='.'
species='hsa'
input_file='./mirbase_ref/mature1.fa'

#############################################

import os

# Get the directory of script
#script = os.path.realpath(__file__)
#print("SCript path:", script)

os.chdir(CurWD)

f_in=open(file=input_file,mode='r')
f_out=open(file=input_file+'.fix',mode='w')

def check_char(input_str):
    for c in input_str:
        if((c!='A')&(c!='C')&(c!='G')&(c!='T')&(c!='U')&(c!='N')&(c!='a')&(c!='c')&(c!='g')&(c!='t')&(c!='n')&(c!='u')&(c!='\n')):
            input_str=str(input_str).replace(c, '')
    return input_str
    
for line in f_in:
    if(line[0]!='>'):
        line=check_char(line)
    f_out.write(line)



f_in.close()
f_out.close()
