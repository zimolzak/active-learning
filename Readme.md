Clinical Concept Adjudication via Active Machine Learning
========

Fillmore, Zimolzak, others

Cf requirements for a "brief communications" article here: https://academic.oup.com/jamia/pages/General_Instructions . 2000 words, 2 tables, 3 figs.

Abstract
========

**Background:** Clinical concept adjudication is the process of determining which records (e.g., lab test records) correspond to a clinical concept or covariate of interest.

**Objective:** Our objective is to design and build a system that allows clinical researchers using VA data to quickly and reliably adjudicate clinical concepts such as lab test results.

**Materials and Methods.** We take advantage of the fact that adjudication is a binary classification task and, as such, it can be scaled up using machine learning techniques. In particular, we use active learning and interactive feature engineering to speed up adjudication.

**Results.** We find ...

**Discussion**

**Conclusion**

Article
========

Background and Significance
--------

- Clinical concept adjudication is the process of determining which records (e.g., lab test records) correspond to a clinical concept or covariate of interest.
- Important as a first step for many database-based analyses
- For example, we might want to find serum creatinine lab test results, or serum free light chain results

- A criterion to distinguish active from smoldering MM is serum creatinine level > 2 mg/dL [173 mmol/L] and renal insufficiency attributable to myeloma (Rajkumar SV, Dimopoulos MA, Palumbo A, *et al.* International Myeloma Working Group updated criteria for the diagnosis of multiple myeloma. Lancet Oncol. 2014 Nov;15(12):e538-48.).
- Thus, it's natural to look for serum creatinine lab results. But this is not simple. If we search for "creatinine" in the EHR's LabChemTestName table, we find >1000 lab test result types, many irrelevant.
- If we make the query more specific - say, "creatinine" followed by "serum" - we get a much more specific list (64 result types), but many true positives are missed.
- Bottom line: even for a simple lab like serum creatinine, to find all the serum creatinine lab results in the VA's EHR, we - or someone - need to do a careful process of adjudication.

- Current process
    - Our current process is designed to harmonize test results from 144 independent clinical laboratories.
    - It relies on subject matter experts (SMEs) first to design a search for appropriate laboratory test names.
    - Database technicians pull candidate record types into Excel.
    - then two SMEs (MDs) label every existing record type, evaluating for appropriate specimen types (e.g. whole blood, urine, cerebrospinal fluid), units, value ranges, and laboratory test names.
    - SMEs generally accomplish this using a spreadsheet that can be sorted and filtered. (Raju SP, Ho Y-L, Zimolzak AJ, Katcher B, Cho K, Gagnon DR. Validation of Laboratory Values in a Heterogeneous Healthcare System: The US Veterans Affairs Experience. 31st International Conference on Pharmacoepidemiology & Therapeutic Risk Management (ICPE). Boston; 8/22-26/2015.)
    - SMEs resolve disagreements.
    - DB ids and labels of "yes"- and "no"-labeled record types are entered in new DB table as an "adjudicated concept".
    - The spreadsheet is kept as documentation.
    - Drawbacks:
        - Time-consuming, hard to scale
        - Adjudicated concept goes out-of-date as new record types are added
        - Hard for end-user to understand, validate, or adapt adjudicated concept

- Related to a bunch of other problems.
    - *OMOP (or other data models)*
    - The LOINC standard has been developed to identify clinical laboratory test results; previous authors have described mapping their local data to this standard. (Khan AN, Griffith SP, Moore C, Russell D, Rosario AC Jr, Bertolli J. Standardizing laboratory data by mapping to LOINC. J Am Med Inform Assoc. 2006 May-Jun;13(3):353-5.)
    - Mappings of local laboratory tests to LOINC may be erroneous, as well (Lin MC, Vreeman DJ, McDonald CJ, Huff SM. Correctness of Voluntary LOINC Mapping for Laboratory Tests in Three Large Institutions. AMIA Annu Symp Proc. 2010 Nov 13;2010:447-51.).
    - Previous authors have faced similar lab result harmonization problems. For example, the Mini-Sentinel program had to take clinical laboratory results from twelve diverse data partners and deal with inconsistent units and LOINC availability, among other challenges addressed by hands-on quality checking. (Raebel MA, Haynes K, Woodworth TS, Saylor G, Cavagnaro E, Coughlin KO, Curtis LH, Weiner MG, Archdeacon P, Brown JS. Electronic clinical laboratory test results data tables: lessons from Mini-Sentinel. Pharmacoepidemiol Drug Saf. 2014 Jun;23(6):609-18.)
    - *non medicine stuff? Tamr etc?? & 1 other?* (Held, Stonebraker, Davenport, Ilyas, Brodie, Palmer, Markarian. Getting Data Right. 2016. O'Reilly Media, Sebastopol, CA.)
    - *HSR-DATA list search*

Objective
--------

Our objective is to design and build a system that allows clinical researchers using VA data to quickly and reliably adjudicate clinical concepts such as lab test results. We do so by taking advantage of the fact that adjudication is a binary classification task, and as such, it can be scaled up using machine learning techniques. In particular, we use active learning and interactive feature engineering to speed up adjudication. Our tools is interactive and UI focused - the expert labels examples, can also specify features, rules, synthetic examples.

Materials and Methods
--------

We developed software to speed up the process of adjudication using active machine learning and interactive feature engineering, as follows.

First, we developed a basic system to build a model for predicting the whether a candidate lab test type is what we are looking for or not.
Given a set of lab tests that have been labelled as being of interest or not, the system builds a model to predict, for the remaining lab tests, whether they are of interest or not.
The starting point of this model is the spreadsheet described above, which contains columns with text describing each lab test result, the units of the test, the hospital and region where this test is used, and information about the distribution of results of this lab test. 
We explored the use of several machine learning algorithms, including L1-regularized logistic regression, Random Forests, and Support Vector Machines.

We chose the following initial features for use by these algorithms.
We used a bag-of-words encoding for textual fields like the test name and other descriptors (topography, component, specimen).
In a bag-of-words encoding of a textual field, one adds a distinct feature for each vocabulary word; the feature's value for a given example is the number of times that word occurs in that example.
We used a categorical encoding for short textual fields, including the station (i.e., the hospital) identifier, the VISN (i.e., the region) identifier, the units of the lab test, and the LOINC code associated with the lab test.
We used as-is the numerical fields describing the distribution of the associated lab test results, including the number of associated results, and their minimum value, maximum value, and percentile information.
Additionally, we added as a feature a Kolmogorov-Smirnov statistic that compares, for an individual example lab test, the distribution of that test's results relative to the overall distribution of all positive training examples' results.

We evaluated this basic system using seven datasets that had been already adjudicated by VA experts.
These datasets, and basic information about them, are shown in Table 1.
[Table 1 should show:
* The target we are looking for, e.g., HGB, 
* If possible, the query or queries used to generate candidates
* The number of examples overall
* The number of examples labeled positive and negative
]
We compared the performance of three algorithms in the context of this basic system: Logistic regression with an l1 penalty (Lasso), support vector machines (SVM), and random forests. 
We used 10-fold cross validation to evaluate the accuracy of the system using each algorithm.
Results are shown in Figure 1.
[Figure 1: Shows the 10-fold cross validation accuracy]
As this table shows, the highest accuracy is achieved using Random Forests, with Lasso a close second.
[Comment: should move this to Results]
However, Lasso is nearly as good as Random Forests and it has the advantage that it is easy for end users to understand the basis of the models predictions.
We dropped SVM from further consideration because it has the worst performance and also is not as easy to interpret its results.

Second, we enhanced this basic system with an active learning approach, specifically, a pool-based active learning approach.
In active learning, the system tries to choose the next example to present to the user and request a label for so as to minimize the number of labels the user will need to provide to train a high quality machine learning algorithm.
We considered several active learning approaches.
A baseline approach is to randomly sample the next example to label.
A simple approach is to choose as the next example to label the example for which the margin between the model's probability of a positive label and that of a negative label is minimized.
For example, if the system is uncertain about an example's label, so it assigns the probability of a positive label to be 51 percent and that of a negative label to be 49 percent, then the margin is 2 percent; in contrast, the margin if the probability of a positive label is 99 percent and that of a negative label is 1 percent is 98 percent.
Another approach is variance reduction, in which the next example is chosen so as to maximially reduce the prediction variance.
For logistic regression, variance reduction constitutes a stepwise optimal approach to choosing the next example [Schein and Ungar, 2007].

We evaluated the efficacy of these active learning statistics for the purpose of lab adjudication as follows.
Using the seven adjudicated datasets summarized in Table 1, we simulated the active learning process under Random Forests and each statistic.
We plotted learning curves, showing, for each dataset, the 10-fold cross validation accuracy at each step in the active learning process, i.e., after each additional example was labelled (with its previously adjudicated ground truthlabel) in the simulation.
[Figure 2: Shows the learning curves]

Third, we designed and built a user interface around this enhanced system.
This interface was designed as a single-page web application, with a front-end written in ReactJS and a back-end written in Python.
The interface allows users to view both the original table of data elements and the feature matrix that the learning algorithm is based on.
These tables can be looked at separately or viewied side-by-side.
The tables can be ordered by any column, including, most importantly, the active learning statistic of interest.
As the user labels examples within the tool's interfact, these statistics are recomputed and the table is reordered.

In general, in addition to labelling examples, feature engineering can be quite useful as a way to increase a machine learning system's accuracy quickly.
In our tool, the feature matrix is initialized as described above for the basic system.
However, we also provide the user the ability to interact with the feature matrix by adding or removing examples.
We allow all features, including, for example, individual features corresponding to a single vocabulary word, to be removed.
We allow bag-of-word, categorical, or numerical features to be added, both in case they have been previously removed and in case there is a reason to treat a particular data element differently from our default (e.g., treating the lab test name as a categorical variable instead of using a bag-of-words encoding).
Most important, we allow the user to specify a regular expression relative to a textual column, and create a feature whose value is the count of that regular expression within the column.
This is useful because sometimes a clinician or other expert can look at a text field and easily formulate a pattern that should be excluded or included; including a feature that matches that pattern can substantially increase the ability of the machine learning system to correctly classify examples.
For example, [Andy, do you have an example?].

We evaluated the ability of this tool to speed up the adjudication process as follows.
We first instrumented our tool to record all actions taken within the tool, including labelling examples, sorting the table, and adding features and removing features, along with the time each action was taken.
We used this instrumentation to evaluate the speed and quality with which adjudication can be done using the tool, as follows.
We considered the adjudication of two target lab tests, XXX and YYY.
For each target lab test, we constructed a table of candidate examples using the previous Standard Operating Protocol described above.
Two clinicians (AZ and DG) adjudicated the results, using the previous SOP and our tool.
For XXX, AZ adjudicated using the SOP first and our tool second, and DG adjudicated using our tool first and the SOP second.
For YYY, roles were reverse: AZ adjudicated using our tool first and the SOP second, and DG adjudicated using the SOP first and our tool second.
Moreover, the clinicians waited 24 hours between the first and second adjudication.
These measures were taken to mitigate the advantage of being the second tool used by a clinician for a particular adjudication task.
We timed how long it took to label using each tool. Results are...
We looked at the concordance for each tool...
We plotted learning curves...

# - Bag-of-words for test name and other descriptors (topography, component, specimen)
# - Categorical encoding for station (hospital), VISN (region), lab test units, LOINC code
# - Numerical encoding of n (number of results of this type), min, max, percentile info
# - Kolmogorov-Smirnov statistic for results' distribution compared to the distribution of all positive training  examples' results' distribution.

# Talk about the web framework

# UI

# Workflow for using this tool

# Methodology for measuring the difference in speed

# Logging functionality

Results
========

We should have some results that relate to the inherent idea


Using seven datasets that have been adjudicated by experts, we compare three algorithms: Logistic regression with an l1 penalty (Lasso), support vector machines (SVM), and random forests. 

We obtain high 10-fold cross-validation accuracy (Table 1):

*insert table here*
 
Using our engineered features with l1-penalized logistic regression, there is rapid convergence to a high-accuracy classifier, even with random sampling of training examples.

*insert learning curves fig here* 

With Random Forests, the convergence is even better:

*insert another learning curves fig here* 

We should have three plots:

Discussion
========

In the future, can adapt the system to monitor the database and ask for new labels as appropriate to keep concepts up-to-date.

Conclusion
========


[Schein and Ungar, 2007] Andrew I. Schein and Lyle H. Ungar. Active learning for logistic regression: an evaluation. Machine Learning (2007) 68: 235–265. https://link.springer.com/content/pdf/10.1007/s10994-007-5019-5.pdf
