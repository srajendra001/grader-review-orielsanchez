RED='\033[0;31m'   # Red color to display errors
GREEN='\033[0;32m'  # Green color to display successes
NC='\033[0m'        # No color to clear out the last used color

CPATH='.:lib/hamcrest-core-1.3.jar:lib/junit-4.13.2.jar'

rm -rf student-submission
rm -rf grading-area

mkdir grading-area

git clone --quiet $1 student-submission
if [[ $? -ne 0 ]]; then
    echo "Repo not found"
    exit 1
fi

echo -e "${GREEN}Finished cloning${NC}"
student_file=`find student-submission/ -name ListExamples.java`
if [[ student_file == "" ]]; then
    echo -e "${RED}File not found"
    exit 1
fi

echo -e "${GREEN}File ListExamples.java Found!"

cp $student_file ./TestListExamples.java grading-area/

grepOut=`cat grading-area/ListExamples.java | grep -E "class\s+ListExamples"`
if [[ $grepOut == "" ]] ; then
    echo -e "${RED}Wrong class name"
    exit 1
fi

echo -e "${GREEN}Correct class name!${NC}"

javac -cp $CPATH grading-area/*.java 2> grading-area/javac-out
if [[ $? -ne 0 ]]; then
    echo -e "${RED}Compilation failed. Fix your shit before submitting :|\n"
    echo " "
    echo "`cat grading-area/javac-out`"
    exit 1
fi

java -cp "$CPATH:grading-area" org.junit.runner.JUnitCore TestListExamples > grading-area/test-output

# All tests pass
okgrep=`cat grading-area/test-output | grep -E "OK"`
if [[ $okgrep != "" ]]; then
    numTests=`echo $okgrep | grep -Eo "\d+"`
    echo -e "${GREEN}All tests passed ($numTests tests)"
    echo -e "${NC}Score: 100%"
    exit 0
fi

lastLine=`cat grading-area/test-output | grep "Tests run"`
numTests=`echo $lastLine | grep -oE "Tests run: \d+" | grep -oE "\d+"`
numFailures=`echo $lastLine | grep -oE "Failures: \d+" | grep -oE "\d+"`
numSuccess=$(( numTests - numFailures ))
score=`echo "scale=2; ($numSuccess*100) / $numTests" | bc`
echo -e "${NC}Score: $score%"
echo -e "Success: $numSuccess, Failure: $numFailures"
