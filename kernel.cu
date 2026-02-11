#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#define N 1024

//The bitonicSort
__global__ void bitonicSort(int* data, int step, int stage, int direction)
{   //I used (ceil) ceiling to solve the decimel isuues with (pow) and round it up
    int k = threadIdx.x + (blockIdx.x * blockDim.x);
    bool Tk = (k % (int)ceil(pow(2, step - stage + 1))) < (int)ceil(pow(2, step - stage));//Threads working
    if (Tk)
        if (direction == 0) {// direction = 0 accending
            if (k / (int)ceil(pow(2, step)) % 2 == 0) {// ascending

                if (data[k] > data[k + (int)ceil(pow(2, step - stage))]) {//if not in order
                    int temp = data[k];
                    data[k] = data[k + (int)ceil(pow(2, step - stage))];
                    data[k + (int)ceil(pow(2, step - stage))] = temp;
                }
            }

            else {//desc
                if (data[k] < data[k + (int)ceil(pow(2, step - stage))]) {//if not in order
                    int temp = data[k];
                    data[k] = data[k + (int)ceil(pow(2, step - stage))];
                    data[k + (int)ceil(pow(2, step - stage))] = temp;

                }
            }
        }
        else { // direction =1 desc
            if (k / (int)ceil(pow(2, step)) % 2 == 0) {//everything inverted
                if (data[k] < data[k + (int)ceil(pow(2, step - stage))]) { //if not in order
                    int temp = data[k];
                    data[k] = data[k + (int)ceil(pow(2, step - stage))];
                    data[k + (int)ceil(pow(2, step - stage))] = temp;
                }
            }
            else {
               
                if (data[k] > data[k + (int)ceil(pow(2, step - stage))]) {//if not in order
                    int temp = data[k];
                    data[k] = data[k + (int)ceil(pow(2, step - stage))];
                    data[k + (int)ceil(pow(2, step - stage))] = temp;
                }
            }
        }
}


//The text file must contain numbers only, and between each number a single space and the file name: bitonicSort_data
int getFileElements(const char* bitonicSort_data) {
    FILE* fp = fopen(bitonicSort_data, "r");
    if (fp == NULL) return -1;

    int count = 0;
    int temp;
    while (fscanf(fp, "%d", &temp) == 1) {
        count++;
    }
    fclose(fp);
    return count;
}

//calculates the next power of 2
int nextPowerOf2(int n) {
    int p = 1;
    while (p < n) {
        p = p * 2;
    }
    return p;
}

//printing methods
void printArrayBefore(int* arr, int n) {
    printf("\n\nBefore sorting: \n\n");
    for (int i = 0; i < n; i++) {
            printf("%d ", arr[i]);
    }
    printf("\n------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n");

}
    void printArrayAfter(int* arr, int n) {
        printf("\n\nAfter sorting: \n\n");
        for (int i = 0; i < n; i++) {
                printf("%d ", arr[i]);
        }
        printf("\n------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n");

    }

    int main(void) {
        const char* inputParams = "bitonicSort_data.txt";

        int NumberOfElements = getFileElements(inputParams);
        int direction =0;
        
        printf("Select Sorting Order: Type '0' for Ascending OR Type '1' for Descending\n");
        scanf("%d", &direction);
        //Checks FILe
        if (NumberOfElements <= 0) {
            printf("Could not read file or file is empty");
            return 1;
        }

        int PowerOf2 = nextPowerOf2(NumberOfElements);        

        //Blocks and threads needed
        //If Powerof2 of the threads is less than N there is no need to use N threads instead we use Powerof2 threads
        int threadsPerBlock;
        if (PowerOf2 < N) {
            threadsPerBlock = PowerOf2;
        }
        else {
            threadsPerBlock = N;
        }
        int blocksPerGrid = (PowerOf2 + threadsPerBlock - 1) / threadsPerBlock;
       
        
        int size = PowerOf2 * sizeof(int);
        int* d_data;
        int* data = (int*)malloc(size);
        cudaMalloc((void**)&d_data, size);
       
        FILE* fp = fopen(inputParams, "r");//saving data

        for (int i = 0; i < NumberOfElements; i++) {
            fscanf(fp, "%d", &data[i]);
        }
        fclose(fp);

        //used for calculating the padding values
        int Max = data[0];
        int Min = data[0];

        for (int i = 1; i < NumberOfElements; i++) {
            if (data[i] > Max) Max = data[i];
            if (data[i] < Min) Min = data[i];
        }
        int PaddingValue;
        if (direction == 0) {
            PaddingValue = Max;
        }
        else {
            PaddingValue = Min;
        }
        //for padding the rest of the data
        for (int i = NumberOfElements; i < PowerOf2; i++) {
            data[i] = PaddingValue;
        }

        printArrayBefore(data, NumberOfElements);

        cudaMemcpy(d_data, data, size, cudaMemcpyHostToDevice);
;
        //each time we excute the kernel in different steps and stages 
        int num_steps = 0;
        int Depth = PowerOf2;
        while (Depth > 1) {
            Depth = Depth/2 ; 
            num_steps++; }//calculates depth logarithm base 2 and number of steps

        for (int step = 1; step <= num_steps; step++)
        {
            for (int stage = 1; stage <= step; stage++)
            {
                bitonicSort <<<blocksPerGrid, threadsPerBlock >>> (d_data, step, stage, direction);
            }
        }
        
        cudaDeviceSynchronize();
        
        cudaMemcpy(data, d_data, size, cudaMemcpyDeviceToHost);

        printArrayAfter(data, NumberOfElements);
        printf("\n\nNumber of blocks used: %d. Number of Threads used per block: %d. Number of total threads used %d. NUmber of used threads %d. Number of padded threads %d.\n\n", blocksPerGrid, threadsPerBlock, threadsPerBlock * blocksPerGrid, (threadsPerBlock * blocksPerGrid) - (PowerOf2 - NumberOfElements), PowerOf2 - NumberOfElements);

        // 12. Cleanup
        free(data);
        cudaFree(d_data);

        return 0;
    }