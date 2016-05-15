# INSTRUCTIONS FOR USING THIS REPOSITORY

In GitHub, files are stored in _repositories_ (often called "repos", for short), which are public and can be viewed by anybody. However, changes to the original files can only be made or approved (after a **pull request**) by the **owners** of the repositories.

To obtain a complete carbon-copy of the files in this repository, simply click `download ZIP` and GitHub will send you the download of the latest version in a folder with the repository name (in this case, `hea_za_spreadsheets`).

Github will not track the individual changes in Excel files. So, if a file is edited, the _entire_ file will have to be committed back to the repo, not just the changes. This is totally painful but is a shortcoming of using spreadsheets, which are a completely innapropriate tool for data storage in the 21st Century!

If you want to work on the files and change them you will have to **fork** the repository to create a new _branch_. Then you **clone** the file you want to work on to your new branch (always include `za_expandabilityfactors.xlsx` in the clone) and then, if you and the owner are happy with you changes, you can do a **pull request** to _merge_ the two files together.

I am busy working on some VBA to install in each spreadsheet to automatically re-write the entire thing JSON, which is a _much_ better format. The results will look something like the JSON files in the `livelihoods` repo. While the JSON file might not at first appear as user-friendly to the uninitiated as an Excel file does when it's opened in Excel itself, it does allow easy web and app development --I mean, who still has Excel installed on their computers and if they do, can they view Excel spreadsheets on their phones or other devices as well?! This will ultimately leading to massive scaled-out public sharing of HEA data, which can only be a good thing.
