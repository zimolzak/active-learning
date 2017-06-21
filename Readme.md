Clinical Concept Adjudication via Active Machine Learning
========

Fillmore, Zimolzak, others

Cf requirements for a "brief communications" article here: https://academic.oup.com/jamia/pages/General_Instructions

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

Points:

- Clinical concept adjudication is the process of determining which records (e.g., lab test records) correspond to a clinical concept or covariate of interest.
- Important as a first step for many database-based analyses
- For example, we might want to find serum creatinine lab test results, or serum free light chain results
    - A criterion to distinguish active from smoldering MM is, per , "serum creatinine level > 2 mg/dL [173 mmol/L] and renal insufficiency attributable to myeloma". Thus, it's natural to look for serum creatinine lab results. But this is not simple. If we search for "creatinine" in the EHR's LabChemTestName table, we find >1000 lab test result types, many irrelevant.
    - If we make the query more specific - say, "creatinine" followed by "serum" - we get a much more specific list (64 result types), but many true positives are missed.
    - Bottom line: even for a simple lab like serum creatinine, to find all the serum creatinine lab results in the VA's EHR, we - or someone - need to do a careful process of adjudication.
- Current process
    - Recapitulate lab adjudication protocol (Lab Adjudication Protocol_JAN2016.pdf):
        - Database technicians pull candidate record types into Excel:
        - Two MDs label every existing record type (& resolve disagreements):
        - DB ids and labels of "yes"- and "no"-labeled record types entered in new DB table as "adjudicated concept". (Excel spreadsheet kept as documentation.)
    - Drawbacks:
        - Time-consuming, hard to scale
        - Adjudicated concept goes out-of-date as new record types are added
        - Hard for end-user to understand, validate, or adapt adjudicated concept
- Related to a bunch of other problems.
    - OMOP
    - LOINC
    - **Mini-sentinel** paper(s) (AZ has refs)
    - non medicine stuff? Tamr etc?? & 1 other?
    - *note* check refs of the "search EMR paper" refs 10 & 5?? of: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4288074/
    - david, sara, me, et al poster? and refs of that paper.
    - HSR-DATA list search
    - Gagnon paper about dementia (not lab) PMID 24701364 

Objective
--------

Our objective is to design and build a system that allows clinical researchers using VA data to quickly and reliably adjudicate clinical concepts such as lab test results. We do so by taking advantage of the fact that adjudication is a binary classification task, and as such, it can be scaled up using machine learning techniques. In particular, we use active learning and interactive feature engineering to speed up adjudication. Our tools is interactive and UI focused - the expert labels examples, can also specify features, rules, synthetic examples.

Materials and Methods
--------

We use the following features.

- Bag-of-words for test name and other descriptors (topography, component, specimen)
- Categorical encoding for station (hospital), VISN (region), lab test units, LOINC code
- Numerical encoding of n (number of results of this type), min, max, percentile info
- Kolmogorov-Smirnov statistic for results' distribution compared to the distribution of all positive training  examples' results' distribution.

Talk about the web framework

UI

Workflow for using this tool

Methodology for measuring the difference in speed

Logging functionality

Results
========

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
