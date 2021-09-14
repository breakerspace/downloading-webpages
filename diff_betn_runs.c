#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <dirent.h>
#include <unistd.h>
#include <errno.h>
#include <math.h>

#define node_length 10000
#define number_nodes 10000

typedef struct node
{
	char *label;
}node;

int read_all_nodes(char* file, node* all_nodes, int no_nodes, int len_node);
int read_diff_nodes(char* file, node* all_nodes, int no_nodes, int len_node, int end);
int find_node(char* node_label, node* all_nodes, int end);
void print_nodes(char* file, node* all_nodes, int start, int end);
void free_nodes(node* all_nodes, int end);

int main( int argc, char *argv[] ) {
	
	if(argc < 4) {
		printf("Format: ./a.out <rank> <run_no.> <trial_no> <file_path>");
		exit(1);
	}

	int rank = atoi(argv[1]);
	int run = atoi(argv[2]);
	int trial = atoi(argv[3]);
	int len_node = node_length;
	int no_nodes = number_nodes;
	char dom_fname[65], edg_fname[65], res_fname[65];
	char all_dom_fname[65], all_edg_fname[65], all_res_fname[65];

	int diff_domains, diff_edges, diff_resources;
	
	sprintf(dom_fname, "%s%s%d%s%d%s%d%s", argv[4], "trial", trial, "_run", run, "_top", rank, "_domains.txt"); 
	sprintf(edg_fname, "%s%s%d%s%d%s%d%s", argv[4], "trial", trial, "_run", run, "_top", rank, "_edges.txt"); 
	sprintf(res_fname, "%s%s%d%s%d%s%d%s", argv[4], "trial", trial, "_run", run, "_top", rank, "_resources.txt"); 
	sprintf(all_dom_fname, "%s%s%d%s%d%s", argv[4], "trial", trial, "_top", rank, "_domains.txt"); 
	sprintf(all_edg_fname, "%s%s%d%s%d%s", argv[4], "trial", trial, "_top", rank, "_edges.txt"); 
	sprintf(all_res_fname, "%s%s%d%s%d%s", argv[4], "trial", trial, "_top", rank, "_resources.txt"); 

	node *domains = malloc(no_nodes * sizeof(*domains));
	node *edges = malloc(no_nodes * sizeof(*edges));
	node *resources = malloc(no_nodes * sizeof(*resources));

	int no_domains = read_all_nodes(all_dom_fname, domains, no_nodes, len_node);
	
	if(no_domains == 0) 
		diff_domains = read_all_nodes(dom_fname, domains, no_nodes, len_node);
	else 
		diff_domains = read_diff_nodes(dom_fname, domains, no_nodes, len_node, no_domains);

	int no_edges = read_all_nodes(all_edg_fname, edges, no_nodes, len_node);

	if(no_edges == 0) 
		diff_edges = read_all_nodes(edg_fname, edges, no_nodes, len_node);
	else 
		diff_edges = read_diff_nodes(edg_fname, edges, no_nodes, len_node, no_edges);

	int no_resources = read_all_nodes(all_res_fname, resources, no_nodes, len_node);

	if(no_resources == 0) 
		diff_resources = read_all_nodes(res_fname, resources, no_nodes, len_node);
	else 
		diff_resources = read_diff_nodes(res_fname, resources, no_nodes, len_node, no_resources);

	no_domains += diff_domains;
	no_edges += diff_edges;
	no_resources += diff_resources;

	printf("%d %d %d\n", diff_domains, diff_edges, diff_resources);

	print_nodes(all_dom_fname, domains, 0, no_domains);
	print_nodes(all_edg_fname, edges, 0, no_edges);
	print_nodes(all_res_fname, resources, 0, no_resources);

	free_nodes(domains, no_domains);
	free_nodes(edges, no_edges);
	free_nodes(resources, no_resources);

}


int read_all_nodes(char* file, node* all_nodes, int no_nodes, int len_node) {
	FILE* fp = fopen(file, "r");
	int i = 0;

	if (fp != NULL) {
		char node_lab[len_node];
		while(fgets(node_lab, len_node, fp) != NULL){
			all_nodes[i].label = (char*) malloc(len_node * sizeof(char));
			strcpy(all_nodes[i].label, node_lab);
			i++;
			
		}
		fclose(fp);
	}

	return(i);
}

int read_diff_nodes(char* file, node* all_nodes, int no_nodes, int len_node, int end) {
	FILE* fp = fopen(file, "r");
	int i = 0;
	if (fp != NULL){
		char node_lab[len_node];
		int ind;
		while(fgets(node_lab, len_node, fp) != NULL){
			ind = find_node(node_lab, all_nodes, end);
			if (ind == -1) {
				all_nodes[end].label = (char*) malloc(len_node * sizeof(char));
				strcpy(all_nodes[end].label, node_lab);
				end++;
				i++;
			}
			
		}
		fclose(fp);
	}

	return(i);
}


int find_node(char* node_label, node* all_nodes, int end){
	int index = -1;
	for(int i = 0; i < end; i++){
		if (all_nodes[i].label == NULL) {
			continue;
		}
		if(strcmp(all_nodes[i].label, node_label) == 0){
			index = i;
			//printf("%d\n", index);
			break;
		}
	}
	return(index);
}

void print_nodes(char* file, node* all_nodes, int start, int end){
	FILE* fp = fopen(file, "w");
	if (fp != NULL){
		for(int i = start; i < end; i++){
			fputs(all_nodes[i].label, fp);
		}
		fclose(fp);
	}
}

void free_nodes(node* all_nodes, int end) {
	for (int i = 0; i < end; i++) {
		free(all_nodes[i].label);
	}
	free(all_nodes);
}