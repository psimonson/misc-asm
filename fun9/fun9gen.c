/* a.c - for fake virii */
#include <stdio.h>
#include <string.h>
#include <errno.h>

/* Convert to hex.
 */
int process(FILE *fin, const char *name)
{
	int c, i;

	/* process file */
	c = fgetc(fin);
	errno = 0;
	if(c != EOF)
		printf("%s_msg:\n\tdb %s%xh", name, (c < 16 ? "0" : ""), c);
	for(i = 1; (c = fgetc(fin)) != EOF && errno == 0; i++) {
		if((i % 8) == 0) {
			printf("\n\tdb %s%xh", (c < 16 ? "0" : ""), c);
		} else if(c == '\n') {
			printf(", 0dh, 0ah");
			i++;
		} else {
			printf(", %s%xh", (c < 16 ? "0" : ""), c);
		}
	}
	printf("\n\t db 24h\n");
	fclose(fin);
	if(errno != 0) {
		fprintf(stderr, "Error: %s\n", strerror(errno));
		return 1;
	}
	return 0;
}
/* Program to create simple output for assembly program.
 */
int main(int argc, char **argv)
{
	FILE *fp;
	int err = 0;
	if(argc < 2) {
		fprintf(stderr, "Usage: %s filename.ext [...]\n", argv[0]);
		return 1;
	}
	while(*++argv != NULL) {
		char *p = strrchr(*argv, '.');
		char buf[100];
		memset(buf, 0, sizeof(buf));
		if(p == NULL) continue;
		memcpy(buf, *argv, p-(*argv));
		buf[p-(*argv)] = '\0';
		if((fp = fopen(*argv, "rt")) == NULL) {
			fprintf(stderr, "Error: Cannot open file for reading.\n");
			err++;
			goto error;
		}
		err += process(fp, buf);
	}
	
error:
	return err;
}
