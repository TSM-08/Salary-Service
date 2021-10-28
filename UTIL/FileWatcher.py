import sys
import time

from watchdog.observers import Observer
from watchdog.events import RegexMatchingEventHandler


class FiLeEventHandler(RegexMatchingEventHandler):
    ALL_FILES = [r".*"]

    def set_run(self, proc):
        self.run = proc

    def __init__(self, regex):
        self.run = None
        if not regex:
            regex = self.ALL_FILES

        super().__init__(regex)

    def on_created(self, event):
        self.run(event)


class FileWatcher:
    def __init__(self, src_path, proc, mask=None):
        self.__src_path = src_path
        self.__event_handler = FiLeEventHandler(mask)
        self.__event_handler.set_run(proc)
        self.__event_observer = Observer()
        self.timer = 1

    def sleep(self, sec):
        self.timer = sec
        return self

    def run(self):
        self.start()
        try:
            while True:
                time.sleep(self.timer)
        except KeyboardInterrupt:
            self.stop()

    def start(self):
        self.__schedule()
        self.__event_observer.start()

    def stop(self):
        self.__event_observer.stop()
        self.__event_observer.join()

    def __schedule(self):
        self.__event_observer.schedule(
            self.__event_handler,
            self.__src_path,
            recursive=False
        )


def test(event):
    print('Test')


if __name__ == "__main__":
    src_path = sys.argv[1] if len(sys.argv) > 1 else '.'
    FileWatcher(src_path, test).run()
