Clinical Concept Adjudication via Active Machine Learning
========

Fillmore, Zimolzak, others

Cf requirements for a "brief communications" article here: https://academic.oup.com/jamia/pages/General_Instructions . 2000 words, 2 tables, 3 figs.

Abstract
========

**Background:** Clinical concept adjudication is the process of determining which records (e.g., lab test records) correspond to a clinical concept or covariate of interest.

**Objective:** Our objective is to design and build a system that allows clinical researchers using VA data to quickly and reliably adjudicate clinical concepts such as lab test results.

**Materials and Methods.** We take advantage of the fact that adjudication is a binary classification task and, as such, it can be scaled up using machine learning techniques.
In particular, we use active learning and interactive feature engineering to speed up adjudication.

**Results.** We find ...

**Discussion**

**Conclusion**

Background and Significance
========

Clinical concept adjudication is the process of determining which records (e.g., lab test records) correspond to a clinical concept or covariate of interest.
This is important as a first step for many database-based analyses.
For example, we might want to find serum creatinine lab test results, or serum free light chain results.
A criterion to distinguish active from smoldering MM is serum creatinine level > 2 mg/dL (173 mmol/L) and renal insufficiency attributable to myeloma [Rajkumar].
Thus, it's natural to look for serum creatinine lab results.
But this is not simple.
If we search for "creatinine" in the EHR's LabChemTestName table, we find >1000 lab test result types, many irrelevant.
If we make the query more specific - say, "creatinine" followed by "serum" - we get a much more specific list (64 result types), but many true positives are missed.
Bottom line: even for a simple lab like serum creatinine, to find all the serum creatinine lab results in the VA's EHR, we - or someone - need to do a careful process of adjudication.

Our current process is designed to harmonize test results from 144 independent clinical laboratories.
It relies on subject matter experts (SMEs) first to design a search for appropriate laboratory test names.
Database technicians pull candidate record types into Excel.
Then two SMEs (MDs) label every existing record type, evaluating for appropriate specimen types (e.g. whole blood, urine, cerebrospinal fluid), units, value ranges, and laboratory test names.
SMEs generally accomplish this using a spreadsheet that can be sorted and filtered. [Raju]
SMEs resolve disagreements.
DB ids and labels of "yes"- and "no"-labeled record types are entered in new DB table as an "adjudicated concept".
The spreadsheet is kept as documentation.
Several drawbacks exist.
The process is time-consuming and hard to scale.
The adjudicated concept goes out-of-date as new record types are added.
Finally, it is hard for the end-user to understand, validate, or adapt adjudicated concept.

In active learning, the system tries to choose the next example to present to the user and request a label for so as to minimize the number of labels the user will need to provide to train a high quality machine learning algorithm.
Active learning has been used in a number of fields in medicine, such as selecting mapping points in an electrophysiology study [Feng], screening citations to include in systematic reviews [Kontonatsios], clinical text processing [Kholghi] [Figueroa] [Nguyen], and phenotyping based on text and billing codes [Chen].
Other refs: [Cohn] [Atlas] [Settles].

This is related to multiple other problems and prior work.
*OMOP (or other data models) (needs expansion on this item).*
The LOINC standard has been developed to identify clinical laboratory test results; previous authors have described mapping their local data to this standard. [Khan]
Mappings of local laboratory tests to LOINC may be erroneous, as well [Lin].
Previous authors have faced similar lab result harmonization problems.
For example, the Mini-Sentinel program had to take clinical laboratory results from twelve diverse data partners and deal with inconsistent units and LOINC availability, among other challenges addressed by hands-on quality checking. [Raebel]
*non medicine stuff? Tamr etc?? & 1 other? (needs expansion)* [Held]
*HSR-DATA list search (needs expansion)*

Objective
========

Our objective is to design and build a system that allows clinical researchers using VA data to quickly and reliably adjudicate clinical concepts such as lab test results.
We do so by taking advantage of the fact that adjudication is a binary classification task, and as such, it can be scaled up using machine learning techniques.
In particular, we use active learning and interactive feature engineering to speed up adjudication.
Our tools is interactive and UI focused - the expert labels examples, can also specify features, rules, synthetic examples.

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
Additionally, we added as a feature a Kolmogorov-Smirnov statistic that compares, for an individual example lab test, the distribution of that test's results relative to the overall distribution of all positive training examples' results.

We evaluated this basic system using seven datasets that had been already adjudicated by VA experts.
These datasets, and basic information about them, are shown in Table __datasets__.

Table __datasets__ should show:
* The target we are looking for, e.g., HGB, 
* If possible, the query or queries used to generate candidates
* The number of examples overall
* The number of examples labeled positive and negative

We compared the performance of three algorithms in the context of this basic system: logistic regression with an L1 penalty (LASSO), support vector machines (SVM), and random forests. 
We used 10-fold cross validation to evaluate the accuracy of the system using each algorithm.

Active learning
--------

We enhanced this basic system with a pool-based active learning approach.
We considered several active learning approaches.
A baseline approach is to randomly sample the next example to label.
A simple approach is to choose as the next example to label the example for which the margin between the model's probability of a positive label and that of a negative label is minimized.
For example, if the system is uncertain about an example's label, so it assigns the probability of a positive label to be 51 percent and that of a negative label to be 49 percent, then the margin is 2 percent; in contrast, the margin if the probability of a positive label is 99 percent and that of a negative label is 1 percent is 98 percent.
Another approach is variance reduction, in which the next example is chosen so as to maximially reduce the prediction variance.
For logistic regression, variance reduction constitutes a stepwise optimal approach to choosing the next example [Schein].

We evaluated the efficacy of these (three?) active learning statistics for the purpose of lab adjudication as follows.
Using the seven adjudicated datasets summarized in Table __datasets__, we simulated the active learning process under Random Forests and each statistic.
We plotted learning curves, showing, for each dataset, the 10-fold cross validation accuracy at each step in the active learning process, i.e., after each additional example was labelled (with its previously adjudicated ground truth label) in the simulation.

Operationalizing as web application
--------

This interface was designed as a single-page web application, with a front-end written in ReactJS and a back-end written in Python.
The interface allows users to view both the original table of data elements and the feature matrix that the learning algorithm is based on.
These tables can be looked at separately or viewied side-by-side.
The tables can be sorted by any column, including, most importantly, the active learning statistic of interest.
As the user labels examples within the tool's interface, these statistics are recomputed and the table is reordered.

In general, in addition to labelling examples, feature engineering can be quite useful as a way to increase a machine learning system's accuracy quickly.
In our tool, the feature matrix is initialized as described above for the basic system.
However, we also allow the user to adding or removing any features, including, for example, individual features corresponding to a single vocabulary word.
We allow bag-of-words, categorical, or numerical features to be added, both in case they have been previously removed and in case there is a reason to treat a particular data element differently from our default (e.g., treating the lab test name as a categorical variable instead of using a bag-of-words encoding).
Most important, we allow the user to specify a regular expression relative to a textual column, and create a feature whose value is the count of that regular expression within the column.
This is useful because sometimes a clinician or other expert can look at a text field and easily formulate a pattern that should be excluded or included; including a feature that matches that pattern can substantially increase the ability of the machine learning system to correctly classify examples.
For example, if the SME is interested in blood hemoglobin lab values, it is likely that any laboratory test names containing "free" should be excluded, because *FREE HGB* refers to a laboratory test different from the one of interest.

Time savings
--------

To evaluate the ability of this tool to speed up the adjudication process, we added logging functionality.
Our tool records all actions taken by the user (including labelling examples, sorting the table, and adding or removing features) along with a time stamp.
XXX and YYY were selected as lab tests for two clinicians adjudicate for the purposes of testing.
For XXX, AZ adjudicated using the SOP first and our tool second, and DG adjudicated using our tool first and the SOP second.
For YYY, roles were reversed: AZ adjudicated using our tool first and the SOP second, and DG adjudicated using the SOP first and our tool second.
Moreover, the clinicians waited 24 hours between the first and second adjudication, to mitigate any advantage from adjudicating the same lab test twice.
We timed how long it took to label using each tool.
Inter-clinician agreement for each combination of tool and lab test were measured by Cohen's kappa.
Learning curves were also plotted for each....

Results
========

Using seven datasets that have been adjudicated by experts, we compare three algorithms: Logistic regression with an L1 penalty (LASSO), support vector machines (SVM), and random forests.
We obtain high 10-fold cross-validation accuracy (Table __crossvaltable__).
Further results are shown in Figure __crossvalfig__.
The highest accuracy is achieved using Random Forests, with LASSO a close second.
However, LASSO is nearly as good as Random Forests and it has the advantage that it is easy for end users to understand the basis of the models predictions.
We dropped SVM from further consideration because it has the worst performance, and it is not as easy to interpret its results.
 
Using our engineered features with L1-penalized logistic regression, there is rapid convergence to a high-accuracy classifier, even with random sampling of training examples (Figure __lassocurve__).
With Random Forests, the convergence is even better (Figure __rfcurve__).
Regarding feature importance, the feature with the highest coefficient was.... (possibly K-S statistic).

Discussion
========

In the future, can adapt the system to monitor the database and ask for new labels as appropriate to keep concepts up-to-date.
Limitation: Doesn't tell you "when to stop."
Workable for few thousands of rows: SME can sign off on each row.
Will be workable for 10,000+ if additional "stopping" criterion developed.
Machine learning has been applied to lab data cleaning, but to our knowledge *active* learning has not.

Conclusion
========

We have developed an application that allows clinical researchers access to active machine learning, to rapidly aggregate data elements into a single concept.

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
