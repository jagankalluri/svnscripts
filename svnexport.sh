# !/bin/bash
# script  : runList.sh
# author  : Srinath (skuppann, Release Engineer)
# date    : 12/07/2016
# comments: This scripts cherry picks revisions based on "commit messages" and merges
#           to a local workspace, tracks it in audit file and commits the merge back
# ------------------------------------------------------------------------------- #

#Loading the required variables from the input file.
COMMA_SEPARATED_COMMITMSGS=$1
SVN_BASE_BRANCH_URL=$2
SOURCE_BRANCH_URL=$3
TARGET_BRANCH_URL=$4
SVN_USERNAME=$5
SVN_PASSWORD=$6
SVN_WORKSPACE=$7
NEW_SVN_WORKSPACE="$7"_"`date +%Y%m%d`"
FILE_PATH=$NEW_SVN_WORKSPACE/tmp/
SPIDER_ID=$8
STAGING_FOLDER="$8"_"`date +%Y%m%d%H%M%S`"
STAGING_PATH=$9
CODESTATION_STAGING=$9/$STAGING_FOLDER
mkdir -pv $9/$STAGING_FOLDER

# ---- START FUNCTIONS ---- #

# exit the program
exitProgram()
{
    echo >&2 "$@"
    exit 1
}

# Define a timestamp function
timestamp() {
  date +"%Y-%m-%d %H:%M:%S,%3N"
}

#Split on Commas
splitCommasString()
{
  local IFS=,
  local WORD_LIST=($1)
  for word in "${WORD_LIST[@]}"; do
    echo "$word"
  done
}

#Split on Spaces
split_on_space() {
  local IFS=$'\n'
  local WORD_LIST=($1)
  for word in "${WORD_LIST[@]}"; do
    echo "$word"
  done
}

commit()
{
  cd $1
  echo svn resolve -R --username $SVN_USERNAME --password   --accept working $1
  svn resolve -R --username $SVN_USERNAME --password $SVN_PASSWORD  --accept working $1
  echo svn commit --username $SVN_USERNAME
  svn commit --username $SVN_USERNAME --password $SVN_PASSWORD -m "$2"

}

update()
{
  cd $1
  echo svn update --username $SVN_USERNAME
  svn update --ignore-externals --username $SVN_USERNAME --password $SVN_PASSWORD
}

checkTag()
{
isTagExist='';
projects=$(svn ls --username $SVN_USERNAME --password $SVN_PASSWORD $TAG_BRANCH_URL/)
for i in $projects; do
  if [ "$i" == "$1" ];then
                isTagExist="true";
                break
    else
                isTagExist="false";
  fi
done

echo $isTagExist;
}

createTag()
{
version=0
splitCharacter="_V"
while
          ((version+=1))
          arg=$3$splitCharacter$version
          tagsExist=$(checkTag $arg/)
          [ "$tagsExist" == "true" ]
        do : ; done

echo svn copy --username $SVN_USERNAME --password $1 $2$splitCharacter$version  -m "Creating tag for $2$splitCharacter$version"
svn copy --username $SVN_USERNAME --password $SVN_PASSWORD $1 $2$splitCharacter$version  -m "Creating tag for $2$splitCharacter$version"
}

checkout()
{
  echo svn co --username $SVN_USERNAME $1 $2
  svn co --force --username $SVN_USERNAME --password $SVN_PASSWORD $1 $2
}

finalString='';

createDirectory(){
var1=$1

if [ -n "${var1}" ]; then
        case "${var1}" in
                */trunk*)
                        ignoreIndex=`echo "${var1}" | grep -b -o /trunk/ | awk 'BEGIN {FS=":"}{print $1}'`
                        index=ignoreIndex+7
                        var3=`echo ${var1:index}`
                        slashIndex=`expr index "${var3}" /`
                        if [ "$slashIndex" = 0 ]; then
                                finalString=''
                        else
                                start=${var3%/*}
                                length=`echo ${#start}`
                                finalString=`echo ${var3:0:length}`
                        fi
                ;;
                */branches*)
                        ignoreIndex=`echo "${var1}" | grep -b -o /branches/ | awk 'BEGIN {FS=":"}{print $1}'`
                        index=ignoreIndex+10
                        var3=`echo ${var1:index}`
                        slashIndex=`expr index "${var3}" /`
                        var4=`echo ${var3:slashIndex}`
                        slashIndex=`expr index "${var4}" /`
                        if [ "$slashIndex" = 0 ]; then
                                finalString=''
                        else
                                start=${var4%/*}
                                length=`echo ${#start}`
                                finalString=`echo ${var4:0:length}`
                        fi
                ;;
                */tag*)
                        ignoreIndex=`echo "${var1}" | grep -b -o /tag/ | awk 'BEGIN {FS=":"}{print $1}'`
                        index=ignoreIndex+5
                        var3=`echo ${var1:index}`
                        slashIndex=`expr index "${var3}" /`
                        var4=`echo ${var3:slashIndex}`
                        slashIndex=`expr index "${var4}" /`
                        if [ "$slashIndex" = 0 ]; then
                                finalString=''
                        else
                                start=${var4%/*}
                                length=`echo ${#start}`
                                finalString=`echo ${var4:0:length}`
                        fi
        esac
else
        echo "no argument passed"
fi
}

# ---- END FUNCTIONS ---- #


# ---- MAIN START ---- #

echo "########################## START PROGRAM ##########################" $(timestamp)

# Checkout the Target Branch Code
echo "Checking out the target branch $TARGET_BRANCH_URL@HEAD to svn workspace --> $SVN_USERNAME"
#Creating a svn workspace tag
                echo "Attempting to clean up the SVN workspace specified --> $NEW_SVN_WORKSPACE"
                if [[ "$NEW_SVN_WORKSPACE" != *"`date +%Y%m%d`" ]]
                then
                    echo "It's Previous day Workspace"                    
                elif [[ "$NEW_SVN_WORKSPACE" == *"`date +%Y%m%d`" ]]
                then
                    echo "It's Today's Workspace"
                else
                    echo "There is no workspace available"
                fi

checkout $TARGET_BRANCH_URL $NEW_SVN_WORKSPACE

splitCommasString  "$COMMA_SEPARATED_COMMITMSGS" | while read commitmsg; do

    echo "Updating SVN"
        update $NEW_SVN_WORKSPACE

        # Getting List of Revision numbers based on commit Comment
        revisions="$(svn log --username $SVN_USERNAME --password $SVN_PASSWORD $SOURCE_BRANCH_URL |  perl -e '$/="-"x72;while(<STDIN>){print"$r\n"if((($r)=split)&&/@ARGV/)}' $commitmsg | cut -d' ' -f1 | cut -c2-  | sort )";

        # Removing old commitmsg folder
        echo "Removing old commitmsg folder $commitmsg"
        rm -rf "$FILE_PATH$commitmsg"

        # Creating new commitmsg folder
        echo "Creating new commitmsg folder $commitmsg"
        mkdir -p "$FILE_PATH$commitmsg"

                # Iterater through list of revisions
            split_on_space "$revisions" | while read revision; do

                        echo "Updating SVN"
                        update $NEW_SVN_WORKSPACE

                        #echo "COMMIT_MSG: $commitmsg  : Revision is: $revision"
                        #svn merge --username $SVN_USERNAME --password $SVN_PASSWORD  --accept theirs-full $SOURCE_BRANCH_URL -c $revision $NEW_SVN_WORKSPACE

                        # Commit the code
                        #echo "Committing the merged "
                        #commit $NEW_SVN_WORKSPACE "$commitmsg"
                        #echo "Successfully committing the merged changes"

                          #looping throught no of files in the revision
                                split_on_space "$(svn log --verbose -q --username $SVN_USERNAME --password $SVN_PASSWORD -r $revision $SVN_BASE_BRANCH_URL | awk '{if(NR>3)print}' | sed '$d' | awk '{ $1="";  print}')" | while read fileNameWithPath; do
                                        echo "Creating files and folders for Nexus fileNameWithPath" $fileNameWithPath
                                        cd "$FILE_PATH$commitmsg"
                                        filepath=$SVN_BASE_BRANCH_URL$fileNameWithPath;
                                        echo "filepath URL : $filepath"
                                        fileName=$(echo -e  $fileNameWithPath | awk '{print $NF}' FS="/";)
                                        echo "FileName : $fileName"
                                        createDirectory $fileNameWithPath
                                        echo "Directory path finalString" $finalString
                                        LEN=$(echo ${#finalString})
                                        echo "length $LEN"
                                        if [  $LEN -gt 0 ]; then
                                                mkdir -p $finalString
                                                cd $finalString
                                        else
                                            echo "File in Root folder"
                                        fi
                                        svn export --force --username $SVN_USERNAME --password $SVN_PASSWORD "$filepath" "$fileName"
                                done

                done

                #Creating a release tag
                #echo "Attempting to create the release tag for $RELEASE_NAME"
                #splitVaraiable="_"
                #createTag $TARGET_BRANCH_URL  $TAG_BRANCH_URL/$RELEASE_NAME$splitVaraiable$commitmsg $RELEASE_NAME$splitVaraiable$commitmsg

                #Listing the files in the $commitmsg folder
                echo "Listing the files in the $commitmsg folder"
                cd $FILE_PATH/$commitmsg
                ls -lRt

                #Converting dos2unix
                ./dos2unix *

                cd $FILE_PATH
                #creating zip file
                echo "creating zip file of $commitmsg"
                zip -r "$commitmsg.zip" "$commitmsg"

                #scp -pr $commitmsg.zip sv_citadm@lncibd008:$CODESTATION_STAGING

                echo "copying the zip file to staging path $CODESTATION_STAGING "
                cp $commitmsg.zip $CODESTATION_STAGING

                echo "Changing the Zip file permission"
                cd $CODESTATION_STAGING
                chmod 777 $commitmsg.zip

                # push the content to Nexus
                #curl -v -F "r=releases" -F "g=com.acme.widgets" -F "a=widget" -F "v=0.1-1" -F "p=tar.gz" -F "file=@./widget-0.1-1.tar.gz" -u myuser:mypassword http://localhost:8081/nexus/service/local/artifact/maven/content
                #curl --upload-file $commitmsg.zip -u sv_citadm:Sv_citadm123 $NEXUS_PATH
                cd $FILE_PATH
                rm -rf $commitmsg
                rm $commitmsg.zip
				echo "Removing the previous workspace folder"
				CURRENT_WORKSPACE=`echo -e $SVN_WORKSPACE | sed -r "s/.+\/(.+)/\1/"`
                cd $SVN_WORKSPACE
                cd ..
				find . -name "$CURRENT_WORKSPACE"_"`date +%Y*`" -type d ! -newermt 'today 0:00' -print0 | xargs -0 rm -rf
done

echo "########################## END PROGRAM ##########################" $(timestamp)
echo ;

# ---- MAIN END ---- #



