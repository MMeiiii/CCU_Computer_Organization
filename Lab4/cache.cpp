#include <bits/stdc++.h>
using namespace std;

typedef struct cache
{
    int data;
    int dirty;
} Cache;

Cache **cache_block;
int **LRU;
queue<int> *FIFO;
int fetch = 0, cache_hit = 0, cache_miss = 0, read_data = 0, write_data = 0, bytes_from_mem = 0, bytes_to_mem = 0;

void mapping(int row, int column, int block_size, int label, int address, int replace_policy)
{
    address = address / block_size;
    int index = address % row;
    int find = 0, space = 0, flag = column;

    // read
    if (label == 0)
    {
        read_data++;
    }
    else if (label == 1)
    {
        write_data++;
    }

    // hit?
    for (int i = 0; i < column; i++)
    {
        if (cache_block[index][i].data == address)
        {
            cache_hit++;
            find = 1;
            flag = i;
            break;
        }
    }

    // nonhit
    if (find == 0)
    {
        cache_miss++;
        bytes_from_mem += block_size;

        // space?
        for (int i = 0; i < column; i++)
        {
            if (cache_block[index][i].data == 0)
            {
                space = 1;
                flag = i;
                break;
            }
        }

        // FIFO
        if (space == 0 && replace_policy == 0)
        {
            int out = FIFO[index].front();
            FIFO[index].pop();

            for (int i = 0; i < column; i++)
            {
                if (cache_block[index][i].data == out)
                {
                    flag = i;
                    break;
                }
            }
        }
        // LRU
        else if (space == 0 && replace_policy == 1)
        {
            int max = 0;
            for (int i = 0; i < column; i++)
            {
                if (LRU[index][i] > max)
                {
                    max = LRU[index][i];
                    flag = i;
                }
            }
        }
        cache_block[index][flag].data = address;
        FIFO[index].push(address);
        if (cache_block[index][flag].dirty)
        {
            bytes_to_mem += block_size;
        }
        if (label == 0 || label == 2)
        {
            cache_block[index][flag].dirty = 0;
        }
    }

    for (int i = 0; i < column; i++)
    {
        if (i == flag)
        {
            LRU[index][i] = 0;
        }
        else if (cache_block[index][i].data != 0)
        {
            LRU[index][i]++;
        }
    }

    if (label == 1)
    {
        cache_block[index][flag].dirty = 1;
    }
}

/**
 * --------------------------------------------------------------------------------------
 * cache [cache size] [block size] [associativity] [replace policy] [filename]
 *  0         1            2             3               4              5

 * cache size: 8, 16, …, 256 (KB)
 * block size: 4, 8, 16, …, 128 (B)
 * associativity: 1 (direct mapped), 2, 4, 8, f (fully associative)
 * replace-policy: FIFO, LRU
 * --------------------------------------------------------------------------------------
*/

int main(int argc, char *argv[])
{
    if (argc == 6)
    {
        // initial cache_block
        int row, column;
        if (!strcmp(argv[3], "f"))
        {
            row = 1;
            column = atoi(argv[1]) * 1024 / atoi(argv[2]);
        }
        else
        {
            row = atoi(argv[1]) * 1024 / atoi(argv[2]) / atoi(argv[3]);
            column = atoi(argv[3]);
        }

        cache_block = new Cache *[row];
        LRU = new int *[row];
        FIFO = new queue<int>[row];
        for (int i = 0; i < row; i++)
        {
            cache_block[i] = new Cache[column];
            LRU[i] = new int[column];
        }
        for (int i = 0; i < row; i++)
        {
            for (int j = 0; j < column; j++)
            {
                cache_block[i][j].data = 0;
                cache_block[i][j].dirty = 0;
                LRU[i][j] = 0;
            }
        }

        FILE *f = fopen(argv[5], "r");
        char f_line[25] = "\0";
        int label, address;

        int replace_policy;
        if (!strcmp(argv[4], "FIFO"))
        {
            replace_policy = 0;
        }
        else
        {
            replace_policy = 1;
        }

        // mapping
        while (fgets(f_line, 20, f))
        {
            fetch++;
            sscanf(f_line, "%d %x", &label, &address);
            mapping(row, column, atoi(argv[2]), label, address, replace_policy);
        }

        // write back
        for (int i = 0; i < row; i++)
        {
            for (int j = 0; j < column; j++)
            {

                if (cache_block[i][j].dirty == 1)
                {
                    bytes_to_mem += atoi(argv[2]);
                }
            }
        }

        // print
        cout << "Input file = " << argv[5] << "\n";
        cout << "Demend fetch = " << fetch << "\n";
        cout << "Cache hit = " << cache_hit << "\n";
        cout << "Cache miss = " << cache_miss << "\n";
        cout << "Miss Rate = " << fixed << setprecision(4) << (double)cache_miss / (double)fetch << "\n";
        cout << "Read data = " << read_data << "\n";
        cout << "Write data = " << write_data << "\n";
        cout << "Bytes from memory = " << bytes_from_mem << "\n";
        cout << "Bytes to memory = " << bytes_to_mem << "\n";
    }
    else
    {
        printf("Error input!");
    }
}