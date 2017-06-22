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
    - *OMOP (or other data models)*
    - The LOINC standard has been developed to identify clinical laboratory test results; previous authors have described mapping their local data to this standard. (Khan AN, Griffith SP, Moore C, Russell D, Rosario AC Jr, Bertolli J. Standardizing laboratory data by mapping to LOINC. J Am Med Inform Assoc. 2006 May-Jun;13(3):353-5.)
    - Mappings of local laboratory tests to LOINC may be erroneous, as well (Lin MC, Vreeman DJ, McDonald CJ, Huff SM. Correctness of Voluntary LOINC Mapping for Laboratory Tests in Three Large Institutions. AMIA Annu Symp Proc. 2010 Nov 13;2010:447-51.).
    - Previous authors have faced similar lab result harmonization problems. For example, the Mini-Sentinel program had to take clinical laboratory results from twelve diverse data partners and deal with inconsistent units and LOINC availability, among other challenges addressed by hands-on quality checking. (Raebel MA, Haynes K, Woodworth TS, Saylor G, Cavagnaro E, Coughlin KO, Curtis LH, Weiner MG, Archdeacon P, Brown JS. Electronic clinical laboratory test results data tables: lessons from Mini-Sentinel. Pharmacoepidemiol Drug Saf. 2014 Jun;23(6):609-18.)
    - *non medicine stuff? Tamr etc?? & 1 other?* (Held, Stonebraker, Davenport, Ilyas, Brodie, Palmer, Markarian. Getting Data Right. 2016. O'Reilly Media, Sebastopol, CA.)
    - Our current process is designed to harmonize test results from 144 independent clinical laboratories. It relies on subject matter experts (SMEs) to search for appropriate laboratory test names, and then to evaluate for appropriate specimen types (e.g. whole blood, urine, cerebrospinal fluid), units, value ranges, and laboratory test names. SMEs generally accomplish this using a spreadsheet that can be sorted and filtered. (Raju SP, Ho Y-L, Zimolzak AJ, Katcher B, Cho K, Gagnon DR. Validation of Laboratory Values in a Heterogeneous Healthcare System: The US Veterans Affairs Experience. 31st International Conference on Pharmacoepidemiology & Therapeutic Risk Management (ICPE). Boston; 8/22-26/2015.)
    - *HSR-DATA list search*

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
