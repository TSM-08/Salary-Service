import sys


class LoggingPrinter:
    def __init__(self, filename=None, handle=None):
        if handle:
            self.out_file = handle
        else:
            self.out_file = open(filename, "w")

        self.old_stdout = sys.stdout
        # this object will take over `stdout`'s job
        sys.stdout = self

    # executed when the user does a `print`
    def write(self, text):
        self.old_stdout.write(text)
        self.out_file.write(text)

    # executed when `with` block begins
    def __enter__(self):
        return self

    # executed when `with` block ends
    def __exit__(self, type, value, traceback):
        # we don't want to log anymore. Restore the original stdout object.
        sys.stdout = self.old_stdout
