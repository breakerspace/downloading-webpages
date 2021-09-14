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

def parse(json_element, parent): #, fp1, fp2):
	elem.append(json_element)
	#print(json_element['url'])
	#print_element_details(json_element, len(elem))

	if ((json_element['url'] != None) and (not json_element['url'].startswith('about')) and (not json_element['url'].startswith('data')) and (not json_element['url'].startswith('chrome-error')) and ('-extension:' not in json_element['url'])):
		print_resources(json_element) #, fp1)
	#print(0, prev, parent)
	if 'children' in json_element:
		for c in range(len(json_element['children'])):
			if ((json_element['url'] != None) and (not json_element['url'].startswith('about')) and (not json_element['url'].startswith('data')) and (not json_element['url'].startswith('chrome-error')) and ('-extension:' not in json_element['url'])):
				parent = json_element['url']
			# if json_element['children'][c]['url'] != None:
			# 	child = json_element['children'][c]['url']
			# 	print(parent, child)
			# else:
			# 	continue;
			#if json_element['children'][c]['url'] != None:
				#print(url_to_domain(json_element['url']))
			if ((json_element['children'][c]['url'] != None) and (not json_element['children'][c]['url'].startswith('data:')) and (not json_element['children'][c]['url'].startswith('about')) and (not json_element['children'][c]['url'].startswith('chrome-error'))  and ('-extension:' not in json_element['children'][c]['url'])):
				print_edges(json_element['children'][c], parent) #, fp2)
			parse(json_element['children'][c], parent) #, fp1, fp2)

def print_element_details(json_element, i): #, fp1):

	if json_element['url'] == None:
		fp1.write('URL_'+str(i)+': script\n')
	else:
		fp1.write('URL_'+str(i)+': '+json_element['url']+'\n')

	fp1.write('Type_'+str(i)+': '+json_element['type']+'\n')
	
	if (json_element['headers'] != None) and ('url' in json_element['headers']):
			fp1.write('Header_URL_'+str(i)+': '+json_element['headers']['url']+'\n')
	

def print_resources(json_element): #, fp3):

	if json_element['url'] != None:
		fp3.write(json_element['url']+'\n')   #fp3.write
		fp4.write(url_to_domain(json_element['url'])+'\n')

	#fp3.write(json_element['url']+'\n')   
	

def print_edges(json_element, parent): #, fp2):    #the way "Chain of Implicit Trust" paper does
	#print(parent)
	#parent = url_to_domain(json_element['parent'])
	fp2.write(url_to_domain(parent)+' '+url_to_domain(json_element['url'])+'\n') #fp2.write
	
def url_to_domain(url):

	# if url.find('//www.', 0, 13) == -1:
	# 	if url.find('http', 0, 8) == -1:
	# 		ind1 = 0
	# 	else:
	# 		ind1 = url.find('/')+2
	# else:
	# 	ind1 = url.find('//www.', 0, 13)+6
	# ind2 = url.find('/', 8)
	
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


if not os.path.exists(sys.argv[1]):
	print("File doesn't exist: ", sys.argv[1])
elif os.stat(sys.argv[1]).st_size == 0:
    print('Empty file: ', sys.argv[1])
else:
	with open(sys.argv[1], 'r') as jsonfile:   # sys.argv[3]
		try:
			data = json.load(jsonfile)
			#if file has chrome error data['_root']['data'] != chrome-error://chromewebdata/
			if (data != []):
				parse(data[0], data[0]['url'])
			else:
				print('Empty file: ', sys.argv[1])
		except ValueError:
			#fp = open(sys.argv[1], 'r')
			#data = fp.read()
			print('JSON Error: ', sys.argv[1])

#with open(sys.argv[1], 'r') as jsonfile:   # sys.argv[3]
#	data = json.load(jsonfile)
	#text = jsonfile.read()
#print('Im here')
#n = data['_root']['numResources']
#parse(data[0], data[0]['url'])
# print(data[0]['url'])
# print(len(data))
# if len(data) > 1:
# 	print(url_to_domain(data[1]['url']))
# for d in range(len(data)-1):
# 	#print(d)
# 	#print(d+1, data[d+1]['url'])
# 	parse(data[d+1], data[0]['url'])
# 	print_edges(data[d+1], data[0]['url']) #, fp2)

#parse(data[1])


#fp1.close()
fp2.close()
fp3.close()
fp4.close()

