/* a.c - for fake virii */
#include <stdio.h>
#include <string.h>
#include <errno.h>

/* Convert to hex.
 */
int process(FILE *fin)
{
	int c, i;

	/* process file */
	c = fgetc(fin);
	errno = 0;
	if(c != EOF)
		printf("virii_msg:\n\tdb %xh", c);
	for(i = 0; (c = fgetc(fin)) != EOF && errno == 0; i++) {
		if(i > 0 && (i % 8) == 0) {
			printf("\n\tdb %s%xh", (c < 16 ? "0" : ""), c);
		} else if(c == '\n') {
			printf(", 0%xh, 0%xh", '\r', '\n');
			i++;
		} else {
			printf(", %s%xh", (c < 16 ? "0" : ""), c);
		}
	}
	fclose(fin);
	if(errno != 0) {
		fprintf(stderr, "Error: %s\n", strerror(errno));
		return 1;
	}
	printf(", 24h\n");
	return 0;
}
/* Program to create simple output for assembly program.
 */
int main()
{
	FILE *fp;
	if((fp = fopen("tmp.dat", "rt")) == NULL) {
		fprintf(stderr, "Error: Cannot open file for reading.\n");
		goto error_open;
	}
	return process(fp);
	
error_open:
	return 1;
}
