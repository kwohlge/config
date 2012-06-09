#!/usr/bin/env python3
import os
import glob

def main():
    dfdir = os.path.abspath('dotfiles/.*')
    for df in glob.glob(dfdir):
        if df.endswith('.git'):
            continue
        goodpath = os.path.join(os.path.expanduser('~/'), os.path.basename(df))
        if os.path.exists(goodpath):
            if os.path.samefile(df, goodpath):
                pass
            else:
                print('files differ {0} {1}'.format(df, goodpath))
        else:
            print('linking {0} to {1}'.format(df, goodpath))
            os.symlink(df, goodpath)

if __name__ == '__main__':
    main()
