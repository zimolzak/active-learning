Clinical Concept Adjudication via Active Machine Learning
========

Fillmore, Zimolzak, others

Cf requirements for a "brief communications" article here: https://academic.oup.com/jamia/pages/General_Instructions .
2000 words, 2 tables, 3 figs.

Abstract
========

**Background:** Clinical concept adjudication is the process of determining which records (e.g., lab test records) correspond to a clinical concept or covariate of interest.

**Objective:** Our objective is to design and build a system that allows clinical researchers using VA data to quickly and reliably adjudicate clinical concepts such as lab test results.

**Materials and Methods.** We take advantage of the fact that adjudication is a binary classification task and, as such, it can be scaled up using machine learning techniques.
In particular, we use active learning and interactive feature engineering to speed up adjudication.

**Results.** We find ...

**Discussion**

**Conclusion**

*Flow of the Background section: secondary use is a thing that in theory could be useful in lots of ways --> data is messy --> so adjudication exists --> others have tried --> despite those efforts, here is our current process --> which has drawbacks --> maybe active learning can help.*


Background and Significance
========

Lab data is an important component in much medical research.
You can get it from existing data, a.k.a. "secondary use" [MIT Critical Data].
For example, serum creatinine lab test results are essential for a study comparing the efficacy of several different diuretics [Lederle].
Similarly, serum free light chain lab test results are key indicators in studies of difference in surival multiple myeloma patients.
For example, we might want to find serum creatinine lab test results, or serum free light chain results.
A criterion to distinguish active from smoldering myeloma is serum creatinine level > 2 mg/dL (173 mmol/L) and renal insufficiency attributable to myeloma [Rajkumar].

It's natural simply to look for serum creatinine lab results in the existing database such as the EMR.
But this is not simple.
VA has a data warehouse, which is big [Fihn] but messy [Giroir].
If we search for "creatinine" in the VA data warehouse's LabChemTestName table, we find >1000 lab test result types, many irrelevant.
If we make the query more specific - say, "creatinine" followed by "serum" - we get a much more specific list (64 result types), but many true positives are missed.
Bottom line: even for a simple lab like serum creatinine, to find all the serum creatinine lab results in the VA's electronic health record (EHR), we - or someone - need to do a careful process of adjudication.

Therefore, we have clinical concept adjudication, which is the process of determining which records (e.g., lab test records) correspond to a clinical concept or covariate of interest.
This is important as a first step for many studies using large databases of healthcare records.

Previous authors have faced similar lab result harmonization problems.
The Logical Observation Identifiers Names and Codes (LOINC) standard has been developed to identify clinical laboratory test results; previous authors have described mapping their local data to this standard. [Khan]
But mappings of local laboratory tests to LOINC may be erroneous, as well [Lin].
For example, the Mini-Sentinel program had to take clinical laboratory results from twelve diverse data partners and deal with inconsistent units and LOINC availability, among other challenges addressed by hands-on quality checking. [Raebel]

Despite these efforts, VA data still needs adjudication.
Our current process is designed to harmonize test results from 144 independent clinical laboratories.
It relies on subject matter experts (SMEs) first to design a search for appropriate laboratory test names.
Database technicians pull candidate record types into Excel.
Then two SMEs (MDs) label every existing record type, evaluating for appropriate specimen types (e.g. whole blood, urine, cerebrospinal fluid), units, value ranges, and laboratory test names.
SMEs generally accomplish this using a spreadsheet that can be sorted and filtered. [Raju]
SMEs resolve disagreements.
Database IDs and labels of "yes"- and "no"-labeled record types are entered in new database table as an "adjudicated concept".
The spreadsheet is kept as documentation.

Several drawbacks to that process exist.
The process is time-consuming and hard to scale.
The adjudicated concept goes out-of-date as new record types are added.
Finally, it is hard for the end-user to understand, validate, or adapt the final adjudicated concept.

Active learning presents a possible improved approach.
In active learning, the system tries to choose the next example to present to the user and request a label for so as to minimize the number of labels the user will need to provide to train a high quality machine learning algorithm.
Active learning has been used in a number of fields in medicine, such as selecting mapping points in an electrophysiology study [Feng], screening citations to include in systematic reviews [Kontonatsios], clinical text processing [Kholghi] [Figueroa] [Nguyen], and phenotyping based on text and billing codes [Chen].
Other refs: [Cohn] [Atlas] [Settles].

Other citations:
Unit conversions between LOINC codes. https://academic-oup-com.ezp-prod1.hul.harvard.edu/jamia/article/25/2/192/3871185?searchresult=1
Implementation and management of a biomedical observation dictionary in a large healthcare information system. https://academic-oup-com.ezp-prod1.hul.harvard.edu/jamia/article/20/5/940/728793?searchresult=1
A corpus-based approach for automated LOINC mapping. https://academic-oup-com.ezp-prod1.hul.harvard.edu/jamia/article/21/1/64/695736?searchresult=1
Evaluation of a "Lexically Assign, Logically Refine" Strategy for Semi-automated Integration of Overlapping Terminologies. https://academic-oup-com.ezp-prod1.hul.harvard.edu/jamia/article/5/2/203/740214?searchresult=1
[IMPORTANT] LabRS: A Rosetta stone for retrospective standardization of clinical laboratory test results. https://academic-oup-com.ezp-prod1.hul.harvard.edu/jamia/article/25/2/121/3821186?searchresult=1




Objective
========

We sought to develop a tool that uses machine learning to "extend the reach" of expert lab test annotators, so that the expert doesn't have to enter a decision on each and every row.


Materials and Methods
========

We developed software to speed up the process of adjudication using active machine learning and interactive feature engineering, as follows.

Modeling the response of SMEs
--------

First, we developed a basic system to build a model for predicting the whether a candidate lab test type is what we are looking for or not.
Given a set of lab tests that have been labelled as being of interest or not, the system builds a model to predict, for further lab tests, whether they are of interest or not.

We chose the following initial features for use by these algorithms.
We used a bag-of-words encoding for textual fields like the test name and other descriptors (topography, component, specimen).
In a bag-of-words encoding of a textual field, one adds a distinct feature for each vocabulary word; the feature's value for a given example is the number of times that word occurs in that example.
We used a categorical encoding for short textual fields, including the station (i.e., the hospital) identifier, the VISN (i.e., the region) identifier, the units of the lab test, and the LOINC code associated with the lab test.
We used as-is the numerical fields describing the distribution of the associated lab test results, including the number of associated results, and their minimum value, maximum value, and percentile information.
Additionally, we added as a feature a Kolmogorov-Smirnov statistic that compares, for an individual example lab test, the distribution of that test's results relative to the overall distribution of all positive training examples' results [Smirnov].

We evaluated this basic system using seven datasets that had been already adjudicated by VA experts.
These datasets, and basic information about them, are shown in Table **tableDatasets**.
We compared the performance of three algorithms in the context of this basic system: logistic regression with an L1 penalty (also known as the least absolute shrinkage and selection operator, or LASSO), support vector machines (SVM), and random forests. 
We used 10-fold cross validation to evaluate the accuracy of the system using each algorithm.

Identifier- and observation-level accuracy
--------

In this task, we are labelling lab test identifiers (database ids), but our ultimate purpose in doing so is to identify patient-level observations (lab test results) of interest.
The number of observations associated with each identifier varies widely, ranging from a few lab test results to hundreds of thousands of results.
Thus, there are two relevant ways to compute accuracy: in terms of the number of lab test identifiers correctly classified, or in terms of the number of lab test results correctly classified.
Depending on the situation, these might both be of interest.
If a rough adjudication is desired, it might be sufficient to focus on the identifiers with just the highest number of results; for this, accuracy in terms of identifiers is most important.
For final use in a study, it might be important to ensure accuracy on all results, even those in the long tail of low count identifiers.

Active learning
--------

**probably section gets deleted**

Because our goal in developing this tool is to speed up the process of adjudicating, we considered a pool based active learning approach.
A baseline approach is to randomly sample the next example to label.
# We enhanced this basic system with a pool-based active learning approach [citation needed].
We considered several active learning approaches.
A baseline approach is to randomly sample the next example to label.
A simple approach is to choose as the next example to label the example for which the margin between the model's probability of a positive label and that of a negative label is minimized.
For example, if the system is uncertain about an example's label, so it assigns the probability of a positive label to be 51 percent and that of a negative label to be 49 percent, then the margin is 2 percent; in contrast, the margin if the probability of a positive label is 99 percent and that of a negative label is 1 percent is 98 percent.
A third approach is variance reduction, in which the next example is chosen so as to maximally reduce the prediction variance.
For logistic regression, variance reduction constitutes a stepwise optimal approach to choosing the next example [Schein].

We evaluated the efficacy of these (three?) active learning statistics for the purpose of lab adjudication as follows.
Using the seven adjudicated datasets summarized in Table **tableDatasets**, we simulated the active learning process under Random Forests and each statistic. **FIXME is this true? What AL stat does SVM use, etc.?**
We plotted learning curves, showing, for each dataset, the 10-fold cross validation accuracy at each step in the active learning process, i.e., after each additional example was labelled (with its previously adjudicated ground truth label) in the simulation.

Operationalizing as web application
--------

*Something about the initial text search replacing the SQL data pull person, either here or other section.*

An interface was designed as a single-page web application, with a front-end written in JavaScript and a back-end written in Python + scikit-learn.
The interface allows users to view both the original table of data elements and the feature matrix that the learning algorithm is based on.
These tables can be looked at separately or viewed side-by-side.
The tables can be sorted by any column, including, most importantly, the active learning statistic of interest.
As the user labels examples within the tool's interface, these statistics are recomputed and the table is reordered.

In general, in addition to labelling examples, feature engineering can be quite useful as a way to increase a machine learning system's accuracy quickly.
In our tool, the feature matrix is initialized as described above for the basic system.
However, we also allow the user to add or remove any features, including, for example, individual features corresponding to a single vocabulary word.
We allow bag-of-words, categorical, or numerical features to be added, both in case they have been previously removed and in case there is a reason to treat a particular data element differently from our default (e.g., treating the lab test name as a categorical variable instead of using a bag-of-words encoding).
Most important, we allow the user to specify a regular expression relative to a textual column, and create a feature whose value is the count of that regular expression within the column.
This is useful because sometimes a clinician or other expert can look at a text field and easily formulate a pattern that should be excluded or included; including a feature that matches that pattern can substantially increase the ability of the machine learning system to correctly classify examples.
For example, if the SME is interested in blood hemoglobin lab values, it is likely that any laboratory test names containing "free" should be excluded, because *FREE HGB* refers to a laboratory test different from the one of interest.
#"Oxygen capacity" vs each word separately
For example, if the SME is intersted in serum creatinine, it is likely that any laboratory test names containing "24 HR" should be excluded, even if they do not include "urine", because 24-hour urine creatine is a different laboratory test the one of interest.

Assistance in formulating the initial query
--------

In the current protocol for lab adjudication, the first step in the process is that database technicians pull candidate record types into Excel.
This is done using an SQL query, matching mainly on the lab test name and/or on LOINC codes in the database.
For example, a query for hemoglobin might pull records where the lab test name matches with "HGB" or "Hemoglobin" (case insensitive).
A database technician needs to do this step because many SMEs do not have technical expertise to carry out a database pull.
Additionally, some SMEs do not have access to VA-wide patient-level data needed to compute percentiles on the lab test results.

Splitting out responsibility for the initial pull across two people often results in significant delays.
For example, an initial pull request for hemoglobin might have only included "hemoglobin".
Then, a few days later, when the database technician gives the SME results with that search, the SME might see identifiers like "HGB (hemoglobin)" and realize that they need also to include "HGB" in the search, since there might be results that only include "HGB", not "hemoglobin". 
The SME submits another ticket and needs to wait another day or so to see an updated table.
One other source of slowness here is that executing these pulls can be rather slow, with the query taking several hours to complete, because computing the percentiles in the table requires looking at all matching lab test results, and there may be millions of such results.

In order to avoid this inefficiency, we have integrated the initial search into our interactive tool.
The user specifies search terms using a web form and submits the form to see results.
The query to see results is fast because we pre-computed value percentiles for all lab test identifiers in the VA system (this took over a month of wall clock time).
After verifying that the initial query is well formulated, the user can choose to accept the query and begin labelling examples.
Additionally, if later on the user decides that the query needs to be changed, they can go back to the search form and update the initial query.
After doing so, labels for examples that are still included in the new query remain as-is so work is not lost.

User collaboration in the web application
--------




Results
========

We found that 10-fold cross-validation accuracy was high for all seven laboratory tests, and for all three methods, after all annotated training examples had been added (Table **tableCrossVal**).
For 6 out of 7 laboratory tests, random forests achieved the top cross validation accuracy, and for 6 out of 7 laboratory tests, L1-regularized logistic regression achieved second place or better.
Using our engineered features with L1-penalized logistic regression, there is rapid convergence to a high-accuracy classifier, even with random sampling of training examples (Figure **figLassoLearningCurve**), with all seven laboratory tests above 90% cross validation accuracy with 100 or fewer training examples.
With Random Forests, the convergence occurs with even fewer training examples (Figure **figRandomForestLearningCurve**).
SVM learning curves are not shown because this method had the worst performance, and it is not as easy to interpret its results.
Regarding feature importance, the feature with the highest coefficient (most informative) was often the Kolmogorov-Smirnov statistic (table **tableCoefficients**) **FIXME** make sure this is true once table is fleshed out. "Wide variety of features were most important, depending on the specific lab test.
*Further plot of learning curve(s) based on the count of labs (not treating one row of albumin as equal to any other).*


Discussion
========

We have developed a tool that uses machine learning to assist lab adjudication experts.
No big differences from lab to lab.
Nor from method to method.
LASSO is nearly as good as Random Forests and it has the advantage that it is easy for end users to understand the basis of the models predictions.
First obvs idea: tried several act learning meth (i.e. which one to annotate *next*, doing simply one at a time), but didn't perf > than the rand samp simulation.
However adjudicators even in "Excel style" do bulk labeling (sort filter etc).

Our goal was to speed up the process of expert adjudication of lab results.
Because of the rapid convergence of the learning methods, only about 100 lab data elements need to be adjudicated, and the rest (about 1000, depending on the lab test) can be inferred by the system accurately.
For some labs, this is theoretically as much as a 10-fold improvement in adjudication time.
A possible decision about how many to label: manually review all labs (rows) where N > 1000, let machine predict rest.
Workflow improvements arguably over Excel too (filter, type, mass label are more accessible).

We take advantage of the fact that adjudication is a binary classification task, and as such, it can be scaled up using machine learning techniques.
Our tool is interactive and user interface focused; the expert labels examples but can also specify features, rules, or synthetic examples.
We have further extended our system to support the lab adjudication task from end to end, by also helping with the initial search for candidate lab data elements (search by LOINC, text string, etc.).
Because the tool captures the result of an expert's adjudication, it can also use a database table to publicize what laboratory tests have been adjudicated.

A future improvement would be (1) the ability to "fork" a given adjudication, to update or adapt it for a different study.
In the future, the tool could also be (2) adapted to capturing adjudication from multiple experts, calculating agreement, and returning discordant lab elements to generate consensus.
One next step is to (3) do testing of speed.
To evaluate the ability of this tool to speed up the adjudication process, we have already added logging functionality.
Our tool will record all actions taken by the user (including labelling examples, sorting the table, and adding or removing features) along with a time stamp.
Try it the old and new way, timing how long it took to label using each tool.
We could (4) adapt the system to monitor the database and ask for new labels as appropriate to keep concepts up-to-date.
Another *possible* Future direction: (5) dynamically add rows to spreadsheet: add or subtract junk as in LabChemTestName LIKE '%hgb%' etc. (think about whether this is worth mentioning in this section of paper).

This is related to multiple other problems and prior work.
*OMOP (or other data models) (needs expansion on this item).*
*non medicine stuff? Tamr etc?? & 1 other? (needs expansion)* [Held]
Machine learning has been applied to lab data cleaning, but to our knowledge *interactive* machine learning has not.


References
========

Andrew I. Schein and Lyle H. Ungar. Active learning for logistic regression: an evaluation. Machine Learning (2007) 68: 235–265. https://link.springer.com/content/pdf/10.1007/s10994-007-5019-5.pdf

Rajkumar SV, Dimopoulos MA, Palumbo A, *et al.* International Myeloma Working Group updated criteria for the diagnosis of multiple myeloma. Lancet Oncol. 2014 Nov;15(12):e538-48.

Raju SP, Ho Y-L, Zimolzak AJ, Katcher B, Cho K, Gagnon DR. Validation of Laboratory Values in a Heterogeneous Healthcare System: The US Veterans Affairs Experience. 31st International Conference on Pharmacoepidemiology & Therapeutic Risk Management (ICPE). Boston; 8/22-26/2015.

Feng Y, Guo Z, Dong Z, Zhou XY, Kwok KW, Ernst S, Lee SL. An efficient cardiac mapping strategy for radiofrequency catheter ablation with active learning. Int J Comput Assist Radiol Surg. 2017 Jul;12(7):1199-1207. PMID: 28477277.

Kontonatsios G, Brockmeier AJ, Przybyła P, McNaught J, Mu T, Goulermas JY, Ananiadou S. A semi-supervised approach using label propagation to support citation screening. J Biomed Inform. 2017 Aug;72:67-76. PMID: 28648605.

Kholghi M, Sitbon L, Zuccon G, Nguyen A. Active learning: a step towards automating medical concept extraction. J Am Med Inform Assoc. 2016 Mar;23(2):289-96. PMID 26253132.

Figueroa RL, Zeng-Treitler Q, Ngo LH, Goryachev S, Wiechmann EP. Active learning for clinical text classification: is it better than random sampling? J Am Med Inform Assoc. 2012 Sep-Oct;19(5):809-16. PMID 22707743.

Nguyen DH, Patrick JD. Supervised machine learning and active learning in classification of radiology reports. J Am Med Inform Assoc. 2014 Sep-Oct;21(5):893-901. PMID 24853067.

Chen Y, Carroll RJ, Hinz ER, Shah A, Eyler AE, Denny JC, Xu H. Applying active learning to high-throughput phenotyping algorithms for electronic health records data. J Am Med Inform Assoc. 2013 Dec;20(e2):e253-9. PMID 23851443.

Cohn DA, Atlas LE, Ladner RE. Improving generalization with active learning. Machine Learning 15(2):201-221, 1994.*

Atlas LE, Cohn DA, Ladner RE. Training Connectionist Networks with Queries and Selective Sampling. NIPS 1989.*

Settles, Burr (2010), "Active Learning Literature Survey" (PDF), Computer Sciences Technical Report 1648. University of Wisconsin–Madison.*

Khan AN, Griffith SP, Moore C, Russell D, Rosario AC Jr, Bertolli J. Standardizing laboratory data by mapping to LOINC. J Am Med Inform Assoc. 2006 May-Jun;13(3):353-5.

Lin MC, Vreeman DJ, McDonald CJ, Huff SM. Correctness of Voluntary LOINC Mapping for Laboratory Tests in Three Large Institutions. AMIA Annu Symp Proc. 2010 Nov 13;2010:447-51.

Raebel MA, Haynes K, Woodworth TS, Saylor G, Cavagnaro E, Coughlin KO, Curtis LH, Weiner MG, Archdeacon P, Brown JS. Electronic clinical laboratory test results data tables: lessons from Mini-Sentinel. Pharmacoepidemiol Drug Saf. 2014 Jun;23(6):609-18.

Held, Stonebraker, Davenport, Ilyas, Brodie, Palmer, Markarian. Getting Data Right. 2016. O'Reilly Media, Sebastopol, CA.

Lederle FA, Cushman WC, Ferguson RE, Brophy MT, Fiore LD. Chlorthalidone Versus Hydrochlorothiazide: A New Kind of Veterans Affairs Cooperative Study. Ann Intern Med. 2016 Nov 1;165(9):663-664.

Fihn SD, Francis J, Clancy C, et al. Insights from advanced analytics at the veterans health administration. Health Aff. 2014;33(7):1203-1211.

Giroir BP, Wilensky GR. Reforming the Veterans Health Administration — Beyond Palliation of Symptoms. N Engl J Med. 2015;373(18):1693-1695.

MIT Critical Data, editors. Secondary Analysis of Electronic Health Records. Cham, Switzerland: Springer; 2016.

Smirnov N. Table for Estimating the Goodness of Fit of Empirical Distributions
Ann. Math. Statist. Volume 19, Number 2 (1948), 279-281.


