import sys
import os
import re
import json
import numpy as np

i = 0;
elem = []

#fp1 = open(sys.argv[2], 'a')
fp2 = open(sys.argv[2], 'a')
fp3 = open(sys.argv[3], 'a')
fp4 = open(sys.argv[4], 'a')


def parse(json_element): #, fp1, fp2):
	elem.append(json_element)

	#print_element_details(json_element, len(elem))

	print_resources(json_element) #, fp1)

	for c in range(len(json_element['children'])):
		print_edges(json_element['children'][c]) #, fp2)
		parse(json_element['children'][c]) #, fp1, fp2)


def print_element_details(json_element, i): #, fp1):

	fp1.write('Data_'+str(i)+': '+json_element['data']+'\n')
	
	if json_element['parent']:
		fp1.write('Parent_'+str(i)+': '+json_element['parent']+'\n')
	else:
		fp1.write('Parent_'+str(i)+': Root\n')

	if 'networkData' in json_element:
		if 'request' in json_element['networkData']:
			fp1.write('DocumentURL_'+str(i)+': '+json_element['networkData']['request']['documentURL']+'\n')
			fp1.write('Request URL_'+str(i)+': '+json_element['networkData']['request']['request']['url']+'\n')
			if 'Referer' in json_element['networkData']['request']['request']['headers']:
				fp1.write('Referer_'+str(i)+': '+json_element['networkData']['request']['request']['headers']['Referer']+'\n')
			else:
				fp1.write('Referer_'+str(i)+': No value for referer\n')
		fp1.write('Response URL_'+str(i)+': '+json_element['networkData']['response']['response']['url']+'\n')
		if ('initiator' in json_element['networkData']) and ('url' in json_element['networkData']['initiator']):
			fp1.write('Initiator URL_'+str(i)+': '+json_element['networkData']['initiator']['url']+'\n')
		else:
			fp1.write('Initiator URL_'+str(i)+': No value for initiator url\n')
	else:
		fp1.write('NetworkData_'+str(i)+': No Network Data\n')


def print_resources(json_element): #, fp3):

	if ((not json_element['data'].startswith(':')) and (not json_element['data'].startswith('about')) and (not json_element['data'].startswith('data')) and (not json_element['data'].startswith('chrome-error')) and ('-extension:' not in json_element['data'])):
		fp3.write(json_element['data']+'\n')   
		fp4.write(url_to_domain(json_element['data'])+'\n')

	if ((json_element['parent']) and (not json_element['parent'].startswith(':')) and (not json_element['parent'].startswith('about')) and (not json_element['parent'].startswith('data')) and (not json_element['parent'].startswith('chrome-error')) and ('-extension:' not in json_element['parent'])):
		fp3.write(json_element['parent']+'\n')
		fp4.write(url_to_domain(json_element['parent'])+'\n')
	
	if 'networkData' in json_element:
		if 'request' in json_element['networkData']:
			#fp3.write(json_element['networkData']['request']['documentURL']+'\n')
			#fp3.write(json_element['networkData']['request']['request']['url']+'\n')
			if 'Referer' in json_element['networkData']['request']['request']['headers']:
				ref = json_element['networkData']['request']['request']['headers']['Referer']
				if ((not ref.startswith(':')) and (not ref.startswith('about')) and (not ref.startswith('data')) and (not ref.startswith('chrome-error')) and ('-extension:' not in ref)):
					fp3.write(ref+'\n')
					fp4.write(url_to_domain(ref)+'\n')
		#fp3.write(json_element['networkData']['response']['response']['url']+'\n')
		# if ('initiator' in json_element['networkData']) and ('url' in json_element['networkData']['initiator']):
		# 	fp3.write(json_element['networkData']['initiator']['url']+'\n')
		

def print_edges(json_element): #, fp2):    #the way "Chain of Implicit Trust" paper does

	if ((not json_element['data'].startswith(':')) and (not json_element['data'].startswith('about')) and (not json_element['data'].startswith('data')) and (not json_element['data'].startswith('chrome-error')) and ('-extension:' not in json_element['data'])):
		child = url_to_domain(json_element['data'])
	else:
		child = None
	if ((json_element['parent']) and (not json_element['parent'].startswith(':')) and (not json_element['parent'].startswith('about')) and (not json_element['parent'].startswith('data')) and (not json_element['parent'].startswith('chrome-error')) and ('-extension:' not in json_element['parent'])):
		parent = url_to_domain(json_element['parent'])
	else:
		parent = None
	if parent and child:
		fp2.write(parent+' '+child+'\n')
		if ('networkData' in json_element) and ('request' in json_element['networkData']) and ('Referer' in json_element['networkData']['request']['request']['headers']):
			ref = url_to_domain(json_element['networkData']['request']['request']['headers']['Referer'])
			if ((not ref.startswith('about')) and (not ref.startswith('data')) and (not ref.startswith('chrome-error')) and ('-extension:' not in ref)):
				if parent != ref:
					fp2.write(parent+' '+ref+'\n')
					fp2.write(ref+' '+child+'\n')
				else:
					fp2.write(parent+' '+child+'\n')
		else:
			fp2.write(parent+' '+child+'\n')


def url_to_domain(url):

	# if url.find('//www.', 0, 13) == -1:
	# 	if url.find('http', 0, 8) == -1:
	# 		ind1 = 0
	# 	else:
	# 		ind1 = url.find('/')+2
	# else:
	# 	ind1 = url.find('//www.', 0, 13)+6
	ind1 = 0
	if url.startswith('blob:'):
		if url.find('/', 15) == -1:
			ind2 = len(url)
		else:
			ind2 = url.find('/', 13)
	else:
		if url.find('/', 10) == -1:
			ind2 = len(url)
		else:
			ind2 = url.find('/', 13)

	return url[ind1:ind2]



#if file empty or stack trace error, don't load json
if not os.path.exists(sys.argv[1]):
	print("File doesn't exist: ", sys.argv[1])
elif os.stat(sys.argv[1]).st_size == 0:
    print('Empty file: ', sys.argv[1])
else:
	with open(sys.argv[1], 'r') as jsonfile:   # sys.argv[3]
		try:
			data = json.load(jsonfile)
			#if file has chrome error data['_root']['data'] != chrome-error://chromewebdata/
			if ((not data['_root']['data'].startswith("chrome-error")) and ('-extension:' not in data['_root']['data'])):
				parse(data['_root'])
			else:
				print('Chrome Error: ', sys.argv[1])
		except ValueError:
			#fp = open(sys.argv[1], 'r')
			#data = fp.read()
			print('JSON Error: ', sys.argv[1])

fp1.close()
fp2.close()
fp3.close()
fp4.close()
#fp1.write(n+len(elem))
