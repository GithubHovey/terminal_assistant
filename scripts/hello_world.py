import sys

def main():
    args = sys.argv[1:]
    if args:
        print("Hello, " + " ".join(args) + "!")
    else:
        print("Hello from Python!")

if __name__ == "__main__":
    main()
