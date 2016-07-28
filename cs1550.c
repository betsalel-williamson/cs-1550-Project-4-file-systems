/*
	FUSE: Filesystem in Userspace
	Copyright (C) 2001-2007  Miklos Szeredi <miklos@szeredi.hu>

	This program can be distributed under the terms of the GNU GPL.
	See the file COPYING.

    Edited by Betsalel "Saul" Williamson
    saul.williamson@pitt.edu
    Last edited: Jul 27, 2016 11:22 PM

*/

#define FUSE_USE_VERSION 26

#include <fuse.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <assert.h>

#ifndef _DEBUG
#define _DEBUG
#endif

#ifdef _DEBUG
#define print_debug(s) printf s
#else
#define print_debug(s) do {} while (0)
#endif

//size of a disk block
#define    BLOCK_SIZE 512

//we'll use 8.3 filenames
#define    MAX_FILENAME 8
#define    MAX_EXTENSION 3

//How many files can there be in one directory?
#define MAX_FILES_IN_DIR (BLOCK_SIZE - sizeof(int)) / ((MAX_FILENAME + 1) + (MAX_EXTENSION + 1) + sizeof(size_t) + sizeof(long))

//The attribute packed means to not align these things
struct cs1550_directory_entry {
    int nFiles;    //How many files are in this directory.
    //Needs to be less than MAX_FILES_IN_DIR

    struct cs1550_file_directory {
        char fname[MAX_FILENAME + 1];    //filename (plus space for nul)
        char fext[MAX_EXTENSION + 1];    //extension (plus space for nul)
        size_t fsize;                    //file size
        long nStartBlock;                //where the first block is on disk
    } __attribute__((packed)) files[MAX_FILES_IN_DIR];    //There is an array of these

    //This is some space to get this to be exactly the size of the disk block.
    //Don't use it for anything.
    char padding[BLOCK_SIZE - MAX_FILES_IN_DIR * sizeof(struct cs1550_file_directory) - sizeof(int)];
};

typedef struct cs1550_root_directory cs1550_root_directory;

#define MAX_DIRS_IN_ROOT (BLOCK_SIZE - sizeof(int)) / ((MAX_FILENAME + 1) + sizeof(long))

struct cs1550_root_directory {
    int nDirectories;    //How many subdirectories are in the root
    //Needs to be less than MAX_DIRS_IN_ROOT
    struct cs1550_directory {
        char dname[MAX_FILENAME + 1];    //directory name (plus space for nul)
        long nStartBlock;                //where the directory block is on disk
    } __attribute__((packed)) directories[MAX_DIRS_IN_ROOT];    //There is an array of these

    //This is some space to get this to be exactly the size of the disk block.
    //Don't use it for anything.
    char padding[BLOCK_SIZE - MAX_DIRS_IN_ROOT * sizeof(struct cs1550_directory) - sizeof(int)];
};


typedef struct cs1550_directory_entry cs1550_directory_entry;

//How much data can one block hold?
#define    MAX_DATA_IN_BLOCK (BLOCK_SIZE)

struct cs1550_disk_block {
    //All of the space in the block can be used for actual data
    //storage.
    char data[MAX_DATA_IN_BLOCK]; // 512 * 1 byte
};

typedef struct cs1550_disk_block cs1550_disk_block;

// we need to keep track of the disk by using a bitmap
// size is 5*2^20 for 5 mb or 5242880 bytes
struct cs1550_disk {
    // information
    // is 8960 blocks
    cs1550_disk_block blocks[8960]; // reserve 5242880 bytes - (5242880 bits or 655360 bytes) or 4587520 bytes / 512 bytes

    char bitmap[655360]; // this is 1 byte == 8 bits
};

typedef struct cs1550_disk cs1550_disk;

// that means we store a 0 when the block is empty and 1 when the block is using information

//
typedef struct Singleton {
    cs1550_disk *d;
} *singleton;

singleton get_instance() {
    static singleton instance = NULL;

    if (instance == NULL) {

        // get map for struct
        instance = (singleton) calloc(1, sizeof(struct Singleton));

        print_debug(("Calloc instance\n"));

        // get map for disk
        instance->d = (cs1550_disk *) calloc(1, sizeof(struct cs1550_disk));

        cs1550_root_directory *root = (cs1550_root_directory *) &instance->d->blocks[0];
        root->nDirectories = 0;

    } else {
        print_debug(("Accessed non-null instance\n"));
    }

    return instance;
}

/*
 * Called whenever the system wants to know the file attributes, including
 * simply whether the file exists or not.
 *
 * man -s 2 stat will show the fields of a stat structure
 *
 * @return: 0 on success, with a correctly set structure
 *      -ENOENT if the file is not found
 */
static int cs1550_getattr(const char *path, struct stat *stbuf) {
    print_debug(("Inside get attribute path = %s\n", path));

    //default return that path doesn't exist
    int res = -ENOENT;

    memset(stbuf, 0, sizeof(struct stat));

    print_debug(("Opening disk for read\n"));
    FILE *filePtr = fopen(".disk", "rb");
    if (filePtr == NULL)
        return -EBADF;

    cs1550_disk *disk = get_instance()->d;
    fread(disk, sizeof(struct cs1550_disk), 1, filePtr);
    struct cs1550_root_directory *bitmapFileHeader = (struct cs1550_root_directory *) &disk->blocks[0];

    //our bitmap file header

    //is path the root dir?
    if (strcmp(path, "/") == 0) {
        stbuf->st_mode = S_IFDIR | 0755;
        stbuf->st_nlink = 2;
    } else {
        const int str_length = strlen(path);
        char file_name[9];
//        assert(str_length - 1 <= 8);
        memcpy(file_name, &path[1], str_length - 1);
        file_name[8] = '\0';

        //Check if name is subdirectory
        // if the directory exists
        int i;
        for (i = 0; i < bitmapFileHeader->nDirectories; ++i) {
            if (strcmp(bitmapFileHeader->directories[i].dname, file_name) == 0) {

                //Might want to return a structure with these fields
                stbuf->st_mode = S_IFDIR | 0755;
                stbuf->st_nlink = 2;
                res = 0; //no error

                break;
            }
        }


        //Check if name is a regular file
        /*
            //regular file, probably want to be read and write
            stbuf->st_mode = S_IFREG | 0666;
            stbuf->st_nlink = 1; //file links
            stbuf->st_size = 0; //file size - make sure you replace with real size!
            res = 0; // no error
        */

    }

    print_debug(("Closed disk\n"));
    fclose(filePtr);

    return res;
}

/*
 * Called whenever the contents of a directory are desired. Could be from an 'ls'
 * or could even be when a user hits TAB to do autocompletion
 *
 * This function should look up the input path, ensuring that it is a directory, and then list the contents.
 *
 * To list the contents, you need to use the filler() function.  For example: filler(buf, ".", NULL, 0); adds the
 * current directory to the listing generated by ls -a
 *
 * In general, you will only need to change the second parameter to be the name of the file or directory you want to add
 * to the listing.
 *
 * @return: 0 on success
 *      -ENOENT if the directory is not valid or found
 */
static int cs1550_readdir(const char *path, void *buf, fuse_fill_dir_t filler,
                          off_t offset, struct fuse_file_info *fi) {
    print_debug(("Inside read directory path = %s\n", path));

    // list the contents of the directory at path
    // that means I need to navigate to the path first

    //Since we're building with -Wall (all warnings reported) we need
    //to "use" every parameter, so let's just cast them to void to
    //satisfy the compiler
    (void) offset;
    (void) fi;

    print_debug(("Opening disk for read\n"));
    FILE *filePtr = fopen(".disk", "rb");
    if (filePtr == NULL)
        return -EBADF;

    cs1550_disk *disk = get_instance()->d;
    fread(disk, sizeof(struct cs1550_disk), 1, filePtr);
    struct cs1550_root_directory *bitmapFileHeader = (struct cs1550_root_directory *) &disk->blocks[0];

    // this will contain all of the information about the disk
    print_debug(("nDirectories %d\n", bitmapFileHeader->nDirectories));

    filler(buf, ".", NULL, 0);
    filler(buf, "..", NULL, 0);

    if (strcmp(path, "/") == 0) {
        // need to work on this because it is reading all directories. I just want the current directory
        int i;
        for (i = 0; i < bitmapFileHeader->nDirectories; ++i) {
            print_debug(("directory name %s\n", bitmapFileHeader->directories[i].dname));
            print_debug(("nStartBlock %ld\n", bitmapFileHeader->directories[i].nStartBlock));
            filler(buf, bitmapFileHeader->directories[i].dname, NULL, 0);
        }
    } else {
        // get the directory and list its
        const int str_length = strlen(path);
        char file_name[9];
        memcpy(file_name, &path[1], str_length - 1);
        file_name[8] = '\0';
        int i;
        for (i = 0; i < bitmapFileHeader->nDirectories; ++i) {
            if(strcmp(bitmapFileHeader->directories[i].dname, file_name) == 0){
                print_debug(("I'm in this directory %s\n", file_name));

                // get the cs1550_directory_entry
                cs1550_directory_entry * entry =  (cs1550_directory_entry *) &disk->blocks[bitmapFileHeader->directories[i].nStartBlock];

                int j;
                for (j = 0; j < entry->nFiles; ++j) {
                    filler(buf, entry->files[i].fname, NULL, 0);
                }
                // for nFiles list
                break;
            }
        }
    }


    //This line assumes we have no subdirectories, need to change


    //the filler function allows us to add entries to the listing
    //read the fuse.h file for a description (in the ../include dir)

///** Function to add an entry in a readdir() operation
// *
// * @param buf the buffer passed to the readdir() operation
// * @param name the file name of the directory entry
// * @param stat file attributes, can be NULL
// * @param off offset of the next entry or zero
// * @return 1 if buffer is full, zero otherwise
// */
//    typedef int (*fuse_fill_dir_t)(void *buf, const char *name,
//                                   const struct stat *stbuf, off_t off);

    /*
    //add the user stuff (subdirs or files)
    //the +1 skips the leading '/' on the filenames
    filler(buf, newpath + 1, NULL, 0);
    */
    print_debug(("Closed disk\n"));
    fclose(filePtr);

    return 0;
}

/*
 * Creates a directory. We can ignore mode since we're not dealing with
 * permissions, as long as getattr returns appropriate ones for us.
 *
 * @return: 0 on success
 *      -ENAMETOOLONG if the name is beyond 8 chars
 *      -EPERM if the directory is not under the root dir only
 *      -EEXIST if the directory already exists
 */
static int cs1550_mkdir(const char *path, mode_t mode) {
    print_debug(("Inside make directory path = %s\n", path));

    (void) path;
    (void) mode;

    // get name
    int result = 0;
    int i;
    int slash_count = 0;
    int letter_count = 0;
    const int str_length = strlen(path);
    for (i = str_length; i >= 0; --i) {
        if (path[i] == '/') {
            slash_count++;
            print_debug(("Found '/' =  %d\n", slash_count));
            letter_count = 0; // reset letter count
        } else {
            letter_count++;
        }

        if (slash_count > 1) {
            result = -EPERM;
            break;
        }

        if (letter_count > 8) {
            result = -ENAMETOOLONG;
            break;
        }
    }

    // if directory is not under the root directory
    // this means that the path information is off

    // if name is too long

    if (result == 0) {

        char file_name[9];
        assert(str_length - 1 <= 8);
        memcpy(file_name, &path[1], str_length - 1);
        file_name[8] = '\0';


        // that means

        // rb+
        // open in binary mode for writing
        print_debug(("Opening disk for read\n"));
        FILE *filePtr = fopen(".disk", "rb");
        if (filePtr == NULL)
            return -EBADF;

        cs1550_disk *disk = get_instance()->d;
        fread(disk, sizeof(struct cs1550_disk), 1, filePtr);
        print_debug(("Closed disk\n"));
        fclose(filePtr);
        filePtr = NULL;

        struct cs1550_root_directory *bitmapFileHeader = (struct cs1550_root_directory *) &disk->blocks[0];

        // if the directory exists
        int i;
        for (i = 0; i < bitmapFileHeader->nDirectories; ++i) {
            if (strcmp(bitmapFileHeader->directories[i].dname, file_name) == 0) {
                result = -EEXIST;
                break;
            }
        }

        // else create directory
        if (result == 0) {

            // loop through array
            // we are adding a new directory therefor we can write directly to the end
            print_debug(("file_name %s\n", file_name));
            strcpy(bitmapFileHeader->directories[bitmapFileHeader->nDirectories].dname, file_name);
            print_debug(("dname %s\n", bitmapFileHeader->directories[bitmapFileHeader->nDirectories].dname));

            // get start address
            long start_address = (long) &bitmapFileHeader;
            print_debug(("start_address %ld\n", start_address));

            print_debug(("size of bitmapFileHeader %ld\n", sizeof(bitmapFileHeader)));

            // get current address
            long current_address = (long) &bitmapFileHeader->directories[bitmapFileHeader->nDirectories];
            print_debug(("current_address %ld\n", current_address));
            print_debug(("diff %ld\n", (current_address - start_address)));

            long directories_address = (long) &bitmapFileHeader->directories[1];
            print_debug(("directories_address %ld\n", directories_address));
            print_debug(("diff %ld\n", (directories_address - start_address)));

            directories_address = (long) &bitmapFileHeader->directories[2];
            print_debug(("directories_address %ld\n", directories_address));
            print_debug(("diff %ld\n", (directories_address - start_address)));
            // difference between the two is the distance from the start

            bitmapFileHeader->directories[bitmapFileHeader->nDirectories].nStartBlock =
                    sizeof(struct cs1550_root_directory) +
                    sizeof(struct cs1550_directory_entry) * bitmapFileHeader->nDirectories;

            print_debug(
                    ("nStartBlock %ld\n", bitmapFileHeader->directories[bitmapFileHeader->nDirectories].nStartBlock));

            // will increment the number of directories
        }

        long address = (long) bitmapFileHeader->directories[bitmapFileHeader->nDirectories].nStartBlock;
        cs1550_directory_entry *new_entry = (cs1550_directory_entry *) &disk->blocks[address];

        new_entry->nFiles = 0;

        // this is off. I have a bunch of pointers to memory of size char
        // if I start at location 0 I have the root
        // then after the root there was a size of 512

        bitmapFileHeader->nDirectories++;

        print_debug(("Opening disk for write\n"));
        filePtr = fopen(".disk", "rb+");
        if (filePtr == NULL)
            return -EBADF;

        fwrite(disk, sizeof(struct cs1550_disk), 1, filePtr); //write struct to file
        print_debug(("Closed disk\n"));
        fclose(filePtr);
    }

    return result;
}

/*
 * Removes a directory.
 */
static int cs1550_rmdir(const char *path) {
    (void) path;
    return 0;
}

/*
 * Does the actual creation of a file. Mode and dev can be ignored.
 *
 */
static int cs1550_mknod(const char *path, mode_t mode, dev_t dev) {
    print_debug(("path: %s\n", path));
    (void) mode;
    (void) dev;
    return 0;
}

/*
 * Deletes a file
 */
static int cs1550_unlink(const char *path) {
    (void) path;

    return 0;
}

/*
 * Read size bytes from file into buf starting from offset
 *
 */
static int cs1550_read(const char *path, char *buf, size_t size, off_t offset,
                       struct fuse_file_info *fi) {
    (void) buf;
    (void) offset;
    (void) fi;
    (void) path;

    //check to make sure path exists
    //check that size is > 0
    //check that offset is <= to the file size
    //read in data
    //set size and return, or error

    size = 0;

    return size;
}

/*
 * Write size bytes from buf into file starting from offset
 *
 */
static int cs1550_write(const char *path, const char *buf, size_t size,
                        off_t offset, struct fuse_file_info *fi) {
    (void) buf;
    (void) offset;
    (void) fi;
    (void) path;

    //check to make sure path exists
    //check that size is > 0
    //check that offset is <= to the file size
    //write data
    //set size (should be same as input) and return, or error

    return size;
}

/******************************************************************************
 *
 *  DO NOT MODIFY ANYTHING BELOW THIS LINE
 *
 *****************************************************************************/

/*
 * truncate is called when a new file is created (with a 0 size) or when an
 * existing file is made shorter. We're not handling deleting files or
 * truncating existing ones, so all we need to do here is to initialize
 * the appropriate directory entry.
 *
 */
static int cs1550_truncate(const char *path, off_t size) {
    (void) path;
    (void) size;

    return 0;
}


/*
 * Called when we open a file
 *
 */
static int cs1550_open(const char *path, struct fuse_file_info *fi) {
    (void) path;
    (void) fi;
    /*
        //if we can't find the desired file, return an error
        return -ENOENT;
    */

    //It's not really necessary for this project to anything in open

    /* We're not going to worry about permissions for this project, but
       if we were and we don't have them to the file we should return an error

        return -EACCES;
    */

    return 0; //success!
}

/*
 * Called when close is called on a file descriptor, but because it might
 * have been dup'ed, this isn't a guarantee we won't ever need the file
 * again. For us, return success simply to avoid the unimplemented error
 * in the debug log.
 */
static int cs1550_flush(const char *path, struct fuse_file_info *fi) {
    (void) path;
    (void) fi;

    return 0; //success!
}


//register our new functions as the implementations of the syscalls
static struct fuse_operations hello_oper = {
        .getattr    = cs1550_getattr,
        .readdir    = cs1550_readdir,
        .mkdir    = cs1550_mkdir,
        .rmdir = cs1550_rmdir,
        .read    = cs1550_read,
        .write    = cs1550_write,
        .mknod    = cs1550_mknod,
        .unlink = cs1550_unlink,
        .truncate = cs1550_truncate,
        .flush = cs1550_flush,
        .open    = cs1550_open,
};

//Don't change this.
int main(int argc, char *argv[]) {
    return fuse_main(argc, argv, &hello_oper, NULL);
}
