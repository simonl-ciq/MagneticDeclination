#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>

#define READ_LINE_LEN	256
#define BYTES_LEN		10

uint8_t convert_double_to_varint(double coeff, char *bytes, uint8_t length);
void test(void);

int main(void)
{
	char line[READ_LINE_LEN];
	double coeff;
/*
	char bytes[BYTES_LEN];
	uint8_t bytes_count;
	uint8_t i;
	bool firstenc = true;
*/
	bool first = true;

	puts("WMM Coefficients file converter\n");
/*
	FILE *outenc = fopen("WMM_cof_encoded.mc", "w");
	if (outenc == NULL)
	{
		printf("Cannot open MC output file WMM_cof_encoded.mc\n");
		return EXIT_FAILURE;
	}
*/

	FILE *out = fopen("WMM_COF.mc", "w");
	if (out == NULL)
	{
		printf("Cannot open MC output file WMM_COF.mc\n");
		return EXIT_FAILURE;
	}

	FILE *in = fopen("WMM.COF", "r");
	if (in == NULL)
	{
		printf("Cannot open coefficients input file WMM.COF\n");
		return EXIT_FAILURE;
	}

	fgets(line, READ_LINE_LEN, in);
	coeff = atof(strtok(line, " "));
	if (coeff < 2000 || ((int)coeff % 5 != 0)) {
		printf("Not a valid coefficients file\n");
		return EXIT_FAILURE;
	}

/*
	fprintf(outenc, "const WMM_EPOCH = %0.1ff;\n\n", coeff);
	fprintf(outenc, "var wmm_cof_entries_encoded = [\n");
*/

	fprintf(out, "const WMM_EPOCH = %0.1ff;\n\n", coeff);
	fprintf(out, "var wmm_cof_entries as Array<Double> = [\n");

	while (strncmp(fgets(line, READ_LINE_LEN, in), "9999", 4) != 0)
	{
		// ignore coeff numbers
		strtok(line, " ");
		strtok(NULL, " ");

		// first coeff
		coeff = atof(strtok(NULL, " "));
		if (first)
		{
			fprintf(out, "%0.1f", coeff);
			first = false;
		}
		else
		{
			fprintf(out, ", %0.1f", coeff);
		}
/*
		bytes_count = convert_double_to_varint(coeff, bytes, BYTES_LEN);
		printf("%d => 0x%02hhX\n", bytes_count, bytes[bytes_count-1]);

		for (i = 0U; i < bytes_count; i++)
		{
			if (firstenc)
			{
				firstenc = false;
			}
			else
			{
				fprintf(outenc, ", ");
			}
			fprintf(outenc, "0x%02hhX", bytes[i]);
		}
*/
		// second coeff
		coeff = atof(strtok(NULL, " "));
		fprintf(out, ", %0.1f", coeff);
/*
		bytes_count = convert_double_to_varint(coeff, bytes, BYTES_LEN);
		printf("%d => 0x%02hhX\n", bytes_count, bytes[bytes_count - 1]);

		for (i = 0U; i < bytes_count; i++)
		{
			fprintf(outenc, ", 0x%02hhX", bytes[i]);
		}
*/

		// third coeff
		coeff = atof(strtok(NULL, " "));
		fprintf(out, ", %0.1f", coeff);
/*
		bytes_count = convert_double_to_varint(coeff, bytes, BYTES_LEN);
		printf("%d => 0x%02hhX\n", bytes_count, bytes[bytes_count - 1]);

		for (i = 0U; i < bytes_count; i++)
		{
			fprintf(outenc, ", 0x%02hhX", bytes[i]);
		}
*/
		// fourth coeff
		coeff = atof(strtok(NULL, " \n"));
		fprintf(out, ", %0.1f", coeff);
/*
		bytes_count = convert_double_to_varint(coeff, bytes, BYTES_LEN);
		printf("%d => 0x%02hhX\n", bytes_count, bytes[bytes_count - 1]);

		for (i = 0U; i < bytes_count; i++)
		{
			fprintf(outenc, ", 0x%02hhX", bytes[i]);
		}
*/
	}

/*
	fprintf(outenc, "\n];\n");
	fclose(outenc);
*/

	fprintf(out, "\n];\n");
	fclose(out);

	fclose(in);

	printf("Conversion complete.\n");

	return EXIT_SUCCESS;
}

uint8_t convert_double_to_varint(double coeff, char *bytes, uint8_t length)
{
	int32_t int_coeff = (int32_t)(coeff * 10.0);
	uint8_t bytes_count = 0U;
	bool first_byte = true;
	memset(bytes, '\0', BYTES_LEN);
	printf("%lf, %d, %x\n", coeff, int_coeff, int_coeff);

	do
	{
		printf("\n");
		if (first_byte)
		{
			// set sign flag
			if (int_coeff < 0)
			{
				bytes[bytes_count] = 0x40;
				int_coeff = -int_coeff;
				printf("%02hhx, ", bytes[bytes_count]);
			}

			// set data
			bytes[bytes_count] |= int_coeff & 0x3f;
			printf("%02hhx, ", bytes[bytes_count]);

			if (int_coeff > 0x3f)
			{
				bytes[bytes_count] |= 0x80;
				printf("%02hhx, ", bytes[bytes_count]);
				int_coeff = int_coeff >> 6;
				bytes_count++;
				printf("(%d), ", bytes_count);
			}
			else
			{
				break;
			}

			first_byte = false;
		}
		else
		{
			// set data
			bytes[bytes_count] = int_coeff & 0x7f;
			printf("%02hhx, ", bytes[bytes_count]);

			if (int_coeff > 0x7f)
			{
				bytes[bytes_count] |= 0x80;
				printf("%02hhx, ", bytes[bytes_count]);
				int_coeff = int_coeff >> 7;
				bytes_count++;
				printf("(%d), ", bytes_count);
			}
			else
			{
				break;
			}
		}

	} while (true);
	printf("\n");

	return bytes_count + 1;
}
