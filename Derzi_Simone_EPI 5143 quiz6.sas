libname quiz6 "C:/SAS/EPI 5143";
libname ex "C:/SAS/EPI 5143/Epi 5143 Work Folder/data";

*Create a copy of nencounter dataset in class directory;
data ex.quiz6;
set quiz6.nencounter;
run;

* Visualizing this dataset: 24531 observations;
proc contents data=ex.quiz6;
run;

proc print data=ex.quiz6;
run;

**************************************QUESTION A******************************************;

*Dataset with encounters that started in 2003;
data ex.only2003;
set quiz6.nencounter;
where year(datepart(encstartdtm))=2003;
run;

*Visualizing this dataset: 3327 observations;
proc print data=ex.only2003;
run;

*Dataset with inpatient encounters that started in 2003;
data ex.inpt2003;
set quiz6.nencounter;
where year(datepart(encstartdtm))=2003;
if encvisittypecd='INPT' then output;
run;

*Visualizing this dataset, sorted by encpatwid: 1125 observations;
proc sort data=ex.inpt2003 out=inpt2003;
by encpatwid;
run;

*Visualizing this dataset;
proc print data=inpt2003;/*during the visualization of this dataset, I noticed that encpatWID had duplicates, 
therefore in the next two codes, we will be checking duplicates for encpatWID and encWID as well*/
run;

*Checking encWID duplicates;
proc sort data=ex.inpt2003 nodupkey;/*no duplicates were found for encWID*/
by encwid;
run;


*Checking encpatWID duplicates;
proc sort data=ex.inpt2003 nodupkey;/*51 observations with duplicates were deleted. 
This finding means that if we want to know the number of patients for this assignment questions, we will need to create a flat file for encpatWID*/
by encpatwid;
run;



*The number of patients who had at least 1 inpatient encounter that started in 2003: 1074 patients.
Flattening process;

data ex.flatinpt2003;
set inpt2003;
by encpatwid;
if first.encpatwid then count=1;/*initialize the inpatient flag for each new encpatwid*/
if last.encpatwid then output;/*output the final row for each encpatwid*/
retain count;
run;

*FINAL ANSWER: 1074 patients had at least 1 inpatient encounter that started in 2003.;



**************************************QUESTION B******************************************;
*Number of emergency encounters that started in 2003:2202 observations;
data ex.emerg2003;
set quiz6.nencounter;
where year(datepart(encstartdtm))=2003;
if encvisittypecd='EMERG' then output;
run;


proc sort data=ex.emerg2003 out=em2003;
by encpatwid;
run;


*Flattening process. The number of patients who had at least 1 emergency encounter that 
started in 2003: 1978 patients; 
data ex.flatEMERG2003;
set em2003;
by encpatwid;
if first.encpatwid then count=1;/*initialize the emergency flag for each new encpatwid*/
if last.encpatwid then output;/*output the final row for each encpatwid*/
retain count;
run;


*FINAL ANSWER: 1978 patients had at least 1 emergency room encounter that started in 2003.;


**************************************QUESTION C******************************************;

*Inpatient or emergency encounters that started in 2003: 3327 observations;
data ex.eithertype;
set quiz6.nencounter;
where year(datepart(encstartdtm))=2003;
if (encvisittypecd='EMERG' or encvisittypecd='INPT') then output;
run;

proc sort data=ex.eithertype;
by encpatwid;
run;

*Since all the patients from the above dataset had at least 1 visit (either inpatient or emergency encounter), I will delete the duplicated IDs (encpatwid);
proc sort data=ex.eithertype nodupkey;/*Now we have 2891 patients*/
by encpatwid;
run;

proc print data=ex.eithertype;
run;


*If I proceed with the flattening process, I have the same result.
Flattening process. The number of patients who had at least 1 emergency or inpatient encounter that started in 2003: 2891 patients; 

proc sort data=ex.eithertype out=anytype;
by encpatwid;
run;


data ex.flateithertype;
set anytype;
by encpatwid;
if first.encpatwid then count=1;/*initialize the emergency or inpatient flag for each new encpatwid*/
if last.encpatwid then output;/*output the final row for each encpatwid*/
retain count;
run;


*FINAL ANSWER: 2891 patients had at least 1 visit of either type that started in 2003.;



**************************************QUESTION D******************************************;
*Inpatient or emergency encounters that started in 2003: 3327 observations;
data ex.eithertype;
set quiz6.nencounter;
where year(datepart(encstartdtm))=2003;
if (encvisittypecd='EMERG' or encvisittypecd='INPT') then output;
run;

proc sort data=ex.eithertype;
by encpatwid encvisittypecd;
run;


*Creating a variable called "count" that counts the total number of encounters (of either type);

data ex.final;
set ex.eithertype (keep=encpatwid);
by encpatwid;
if first.encpatwid then count=1;
else count+1;
if last.encpatwid then output;
run;

*Generating a frequency table with the total number of encounters (counts) and its frequency;

ods listing;
options formchar="|----|+|---+=|-/\<>*";
proc freq data=ex.final;
tables encpatwid count;
run;



                                       The FREQ Procedure

                                                     Cumulative    Cumulative
                   count    Frequency     Percent     Frequency      Percent
                   ----------------------------------------------------------
                       1        2556       88.41          2556        88.41
                       2         270        9.34          2826        97.75
                       3          45        1.56          2871        99.31
                       4          14        0.48          2885        99.79
                       5           3        0.10          2888        99.90
                       6           1        0.03          2889        99.93
                       7           1        0.03          2890        99.97
                      12           1        0.03          2891       100.00;



*Generating a frequency table with the number of encounters that each patient had. Note that patient with the code (encpatwid) 910057 had 12 encounters;

ods listing;
options formchar="|----|+|---+=|-/\<>*";
proc freq data=ex.eithertype;
tables encpatwid/out=counts (keep=encpatwid count);
run;
                              
                                      

										The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                       460           1        0.03             1         0.03
                       752           1        0.03             2         0.06
                      1259           1        0.03             3         0.09
                      1354           1        0.03             4         0.12
                      1956           1        0.03             5         0.15
                      2751           1        0.03             6         0.18
                      2954           1        0.03             7         0.21
                      3051           1        0.03             8         0.24
                      3052           1        0.03             9         0.27
                      3158           1        0.03            10         0.30
                      3455           1        0.03            11         0.33
                      3554           1        0.03            12         0.36
                      3856           1        0.03            13         0.39
                      4152           1        0.03            14         0.42
                      4258           1        0.03            15         0.45
                      4353           1        0.03            16         0.48
                      4557           1        0.03            17         0.51
                      5758           1        0.03            18         0.54
                      6052           1        0.03            19         0.57
                      7154           1        0.03            20         0.60
                      7557           1        0.03            21         0.63
                      7560           1        0.03            22         0.66
                      7854           2        0.06            24         0.72
                      7955           1        0.03            25         0.75
                      8554           3        0.09            28         0.84
                      8752           1        0.03            29         0.87
                      9551           1        0.03            30         0.90
                      9860           1        0.03            31         0.93
                     10059           2        0.06            33         0.99
                     10157           1        0.03            34         1.02
                     10660           1        0.03            35         1.05
                     10857           1        0.03            36         1.08
                     11555           1        0.03            37         1.11
                     11556           1        0.03            38         1.14
                     11655           1        0.03            39         1.17
                     11854           1        0.03            40         1.20
                     12053           1        0.03            41         1.23
                     12255           1        0.03            42         1.26
                     12352           1        0.03            43         1.29
                     12658           1        0.03            44         1.32
                     12752           1        0.03            45         1.35
                     12854           1        0.03            46         1.38
                     12954           1        0.03            47         1.41
                     13158           1        0.03            48         1.44
                     14153           1        0.03            49         1.47
                     14254           1        0.03            50         1.50

                                         The SAS System       19:10 Tuesday, March 31, 2020 1341

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                     14755           1        0.03            51         1.53
                     14956           2        0.06            53         1.59
                     15055           1        0.03            54         1.62
                     15351           1        0.03            55         1.65
                     15454           1        0.03            56         1.68
                     15551           3        0.09            59         1.77
                     15653           1        0.03            60         1.80
                     15654           1        0.03            61         1.83
                     16057           1        0.03            62         1.86
                     16360           2        0.06            64         1.92
                     16455           2        0.06            66         1.98
                     16457           1        0.03            67         2.01
                     16656           1        0.03            68         2.04
                     17352           1        0.03            69         2.07
                     17453           1        0.03            70         2.10
                     17558           1        0.03            71         2.13
                     17655           1        0.03            72         2.16
                     17659           1        0.03            73         2.19
                     17959           1        0.03            74         2.22
                     18259           1        0.03            75         2.25
                     18754           1        0.03            76         2.28
                     18860           1        0.03            77         2.31
                     18954           1        0.03            78         2.34
                     18960           1        0.03            79         2.37
                     19153           1        0.03            80         2.40
                     19360           2        0.06            82         2.46
                     19456           1        0.03            83         2.49
                     19657           1        0.03            84         2.52
                     19760           1        0.03            85         2.55
                     19954           1        0.03            86         2.58
                     20154           1        0.03            87         2.61
                     20359           1        0.03            88         2.65
                     20454           1        0.03            89         2.68
                     20955           1        0.03            90         2.71
                     20957           1        0.03            91         2.74
                     21056           1        0.03            92         2.77
                     21060           2        0.06            94         2.83
                     21260           3        0.09            97         2.92
                     21560           1        0.03            98         2.95
                     21660           1        0.03            99         2.98
                     22253           1        0.03           100         3.01
                     22752           1        0.03           101         3.04
                     23154           1        0.03           102         3.07
                     23159           1        0.03           103         3.10
                     23451           1        0.03           104         3.13
                     23757           1        0.03           105         3.16

                                         The SAS System       19:10 Tuesday, March 31, 2020 1342

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                     23954           1        0.03           106         3.19
                     24051           1        0.03           107         3.22
                     24559           1        0.03           108         3.25
                     25254           3        0.09           111         3.34
                     25256           1        0.03           112         3.37
                     25358           1        0.03           113         3.40
                     25555           2        0.06           115         3.46
                     25756           1        0.03           116         3.49
                     25857           1        0.03           117         3.52
                     26859           1        0.03           118         3.55
                     26958           1        0.03           119         3.58
                     27357           1        0.03           120         3.61
                     28252           1        0.03           121         3.64
                     28451           1        0.03           122         3.67
                     28457           1        0.03           123         3.70
                     28959           1        0.03           124         3.73
                     29059           1        0.03           125         3.76
                     29253           1        0.03           126         3.79
                     29757           1        0.03           127         3.82
                     29760           1        0.03           128         3.85
                     29954           2        0.06           130         3.91
                     30055           1        0.03           131         3.94
                     30155           1        0.03           132         3.97
                     30259           1        0.03           133         4.00
                     30458           1        0.03           134         4.03
                     31251           1        0.03           135         4.06
                     32060           1        0.03           136         4.09
                     32656           1        0.03           137         4.12
                     32852           1        0.03           138         4.15
                     32959           1        0.03           139         4.18
                     33053           1        0.03           140         4.21
                     33059           1        0.03           141         4.24
                     33158           1        0.03           142         4.27
                     33458           1        0.03           143         4.30
                     33558           1        0.03           144         4.33
                     34251           2        0.06           146         4.39
                     34256           1        0.03           147         4.42
                     34753           1        0.03           148         4.45
                     34952           1        0.03           149         4.48
                     35559           1        0.03           150         4.51
                     35959           1        0.03           151         4.54
                     36251           1        0.03           152         4.57
                     36459           1        0.03           153         4.60
                     36552           2        0.06           155         4.66
                     36652           1        0.03           156         4.69
                     36953           1        0.03           157         4.72

                                         The SAS System       19:10 Tuesday, March 31, 2020 1343

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                     37054           1        0.03           158         4.75
                     37255           1        0.03           159         4.78
                     37452           1        0.03           160         4.81
                     37553           1        0.03           161         4.84
                     38256           1        0.03           162         4.87
                     38460           3        0.09           165         4.96
                     38552           1        0.03           166         4.99
                     38756           1        0.03           167         5.02
                     38757           1        0.03           168         5.05
                     38953           1        0.03           169         5.08
                     38959           1        0.03           170         5.11
                     39156           1        0.03           171         5.14
                     39159           1        0.03           172         5.17
                     39353           1        0.03           173         5.20
                     40153           1        0.03           174         5.23
                     40251           1        0.03           175         5.26
                     40255           1        0.03           176         5.29
                     40759           1        0.03           177         5.32
                     41053           1        0.03           178         5.35
                     41352           1        0.03           179         5.38
                     41556           1        0.03           180         5.41
                     41651           1        0.03           181         5.44
                     41654           1        0.03           182         5.47
                     41755           1        0.03           183         5.50
                     41851           1        0.03           184         5.53
                     42958           1        0.03           185         5.56
                     43056           1        0.03           186         5.59
                     43957           1        0.03           187         5.62
                     43960           1        0.03           188         5.65
                     44551           1        0.03           189         5.68
                     44556           1        0.03           190         5.71
                     44557           1        0.03           191         5.74
                     44858           1        0.03           192         5.77
                     45357           1        0.03           193         5.80
                     45360           1        0.03           194         5.83
                     45557           1        0.03           195         5.86
                     45754           1        0.03           196         5.89
                     45856           1        0.03           197         5.92
                     45859           1        0.03           198         5.95
                     46057           2        0.06           200         6.01
                     46058           1        0.03           201         6.04
                     46152           1        0.03           202         6.07
                     46552           1        0.03           203         6.10
                     46557           1        0.03           204         6.13
                     46953           2        0.06           206         6.19
                     47159           1        0.03           207         6.22

                                         The SAS System       19:10 Tuesday, March 31, 2020 1344

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                     47552           2        0.06           209         6.28
                     47556           2        0.06           211         6.34
                     47655           1        0.03           212         6.37
                     48152           1        0.03           213         6.40
                     48354           1        0.03           214         6.43
                     48357           1        0.03           215         6.46
                     48360           1        0.03           216         6.49
                     48553           1        0.03           217         6.52
                     48657           1        0.03           218         6.55
                     48754           1        0.03           219         6.58
                     48855           1        0.03           220         6.61
                     48857           1        0.03           221         6.64
                     49053           1        0.03           222         6.67
                     49151           1        0.03           223         6.70
                     49753           1        0.03           224         6.73
                     49951           1        0.03           225         6.76
                     50159           1        0.03           226         6.79
                     50351           1        0.03           227         6.82
                     50360           1        0.03           228         6.85
                     50555           1        0.03           229         6.88
                     50954           1        0.03           230         6.91
                     51055           1        0.03           231         6.94
                     51359           1        0.03           232         6.97
                     51453           1        0.03           233         7.00
                     51654           2        0.06           235         7.06
                     52059           1        0.03           236         7.09
                     52251           1        0.03           237         7.12
                     52260           1        0.03           238         7.15
                     52454           1        0.03           239         7.18
                     52755           1        0.03           240         7.21
                     52851           1        0.03           241         7.24
                     53156           1        0.03           242         7.27
                     53253           1        0.03           243         7.30
                     53551           2        0.06           245         7.36
                     53760           2        0.06           247         7.42
                     54053           1        0.03           248         7.45
                     54054           1        0.03           249         7.48
                     54253           4        0.12           253         7.60
                     54660           1        0.03           254         7.63
                     54759           2        0.06           256         7.69
                     54855           2        0.06           258         7.75
                     55457           2        0.06           260         7.81
                     55553           1        0.03           261         7.84
                     55753           1        0.03           262         7.87
                     55952           1        0.03           263         7.91
                     55959           1        0.03           264         7.94

                                         The SAS System       19:10 Tuesday, March 31, 2020 1345

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                     56056           1        0.03           265         7.97
                     56258           1        0.03           266         8.00
                     56354           1        0.03           267         8.03
                     56358           1        0.03           268         8.06
                     56451           1        0.03           269         8.09
                     56552           2        0.06           271         8.15
                     56553           1        0.03           272         8.18
                     56653           2        0.06           274         8.24
                     56659           1        0.03           275         8.27
                     56954           2        0.06           277         8.33
                     56959           1        0.03           278         8.36
                     57658           1        0.03           279         8.39
                     57855           1        0.03           280         8.42
                     57957           1        0.03           281         8.45
                     58458           1        0.03           282         8.48
                     58659           1        0.03           283         8.51
                     58759           1        0.03           284         8.54
                     59255           1        0.03           285         8.57
                     59952           1        0.03           286         8.60
                     60153           2        0.06           288         8.66
                     60158           1        0.03           289         8.69
                     60251           1        0.03           290         8.72
                     60357           1        0.03           291         8.75
                     60959           1        0.03           292         8.78
                     61056           2        0.06           294         8.84
                     61157           1        0.03           295         8.87
                     61655           1        0.03           296         8.90
                     62655           1        0.03           297         8.93
                     62754           1        0.03           298         8.96
                     62859           1        0.03           299         8.99
                     62951           1        0.03           300         9.02
                     62955           1        0.03           301         9.05
                     63158           1        0.03           302         9.08
                     63356           2        0.06           304         9.14
                     63752           1        0.03           305         9.17
                     63758           2        0.06           307         9.23
                     64160           1        0.03           308         9.26
                     64452           3        0.09           311         9.35
                     64756           1        0.03           312         9.38
                     65259           1        0.03           313         9.41
                     65354           1        0.03           314         9.44
                     65358           1        0.03           315         9.47
                     65552           1        0.03           316         9.50
                     65654           1        0.03           317         9.53
                     65655           1        0.03           318         9.56
                     65758           1        0.03           319         9.59

                                         The SAS System       19:10 Tuesday, March 31, 2020 1346

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                     66152           1        0.03           320         9.62
                     66259           1        0.03           321         9.65
                     66357           2        0.06           323         9.71
                     66551           1        0.03           324         9.74
                     66960           3        0.09           327         9.83
                     67060           2        0.06           329         9.89
                     67153           4        0.12           333        10.01
                     67554           1        0.03           334        10.04
                     67558           1        0.03           335        10.07
                     67655           1        0.03           336        10.10
                     67659           2        0.06           338        10.16
                     67752           1        0.03           339        10.19
                     67757           1        0.03           340        10.22
                     68452           1        0.03           341        10.25
                     68555           4        0.12           345        10.37
                     69158           2        0.06           347        10.43
                     69451           1        0.03           348        10.46
                     69555           2        0.06           350        10.52
                     69558           1        0.03           351        10.55
                     69857           2        0.06           353        10.61
                     70051           1        0.03           354        10.64
                     70660           1        0.03           355        10.67
                     71053           1        0.03           356        10.70
                     71359           1        0.03           357        10.73
                     71851           4        0.12           361        10.85
                     71856           1        0.03           362        10.88
                     71954           1        0.03           363        10.91
                     72053           2        0.06           365        10.97
                     72058           1        0.03           366        11.00
                     72159           1        0.03           367        11.03
                     72251           1        0.03           368        11.06
                     72257           7        0.21           375        11.27
                     72259           1        0.03           376        11.30
                     72352           1        0.03           377        11.33
                     72552           1        0.03           378        11.36
                     72654           1        0.03           379        11.39
                     72752           2        0.06           381        11.45
                     72759           2        0.06           383        11.51
                     72860           1        0.03           384        11.54
                     72958           1        0.03           385        11.57
                     73260           1        0.03           386        11.60
                     73753           2        0.06           388        11.66
                     73851           1        0.03           389        11.69
                     73854           2        0.06           391        11.75
                     73954           1        0.03           392        11.78
                     74152           1        0.03           393        11.81

                                         The SAS System       19:10 Tuesday, March 31, 2020 1347

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                     74355           1        0.03           394        11.84
                     74553           1        0.03           395        11.87
                     74555           1        0.03           396        11.90
                     74656           1        0.03           397        11.93
                     75057           3        0.09           400        12.02
                     75257           1        0.03           401        12.05
                     75352           1        0.03           402        12.08
                     75357           2        0.06           404        12.14
                     75956           1        0.03           405        12.17
                     76153           1        0.03           406        12.20
                     76256           1        0.03           407        12.23
                     76358           1        0.03           408        12.26
                     76451           1        0.03           409        12.29
                     76653           1        0.03           410        12.32
                     76953           1        0.03           411        12.35
                     76959           1        0.03           412        12.38
                     77360           3        0.09           415        12.47
                     77452           1        0.03           416        12.50
                     77457           1        0.03           417        12.53
                     77551           1        0.03           418        12.56
                     77657           1        0.03           419        12.59
                     77854           2        0.06           421        12.65
                     78057           1        0.03           422        12.68
                     78159           3        0.09           425        12.77
                     78656           1        0.03           426        12.80
                     78754           1        0.03           427        12.83
                     78958           1        0.03           428        12.86
                     79059           1        0.03           429        12.89
                     79251           1        0.03           430        12.92
                     79554           1        0.03           431        12.95
                     79556           1        0.03           432        12.98
                     80459           1        0.03           433        13.01
                     80753           1        0.03           434        13.04
                     81260           1        0.03           435        13.07
                     81460           1        0.03           436        13.10
                     81557           1        0.03           437        13.13
                     81753           1        0.03           438        13.17
                     81957           1        0.03           439        13.20
                     82259           1        0.03           440        13.23
                     82353           1        0.03           441        13.26
                     82356           1        0.03           442        13.29
                     82453           1        0.03           443        13.32
                     82459           2        0.06           445        13.38
                     82560           1        0.03           446        13.41
                     82852           1        0.03           447        13.44
                     83056           1        0.03           448        13.47

                                         The SAS System       19:10 Tuesday, March 31, 2020 1348

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                     83060           1        0.03           449        13.50
                     83159           1        0.03           450        13.53
                     83253           1        0.03           451        13.56
                     83659           1        0.03           452        13.59
                     83956           2        0.06           454        13.65
                     84057           2        0.06           456        13.71
                     84554           1        0.03           457        13.74
                     85056           1        0.03           458        13.77
                     85455           1        0.03           459        13.80
                     85856           1        0.03           460        13.83
                     86054           1        0.03           461        13.86
                     86257           1        0.03           462        13.89
                     86258           1        0.03           463        13.92
                     86758           1        0.03           464        13.95
                     86858           1        0.03           465        13.98
                     86960           1        0.03           466        14.01
                     87554           1        0.03           467        14.04
                     87755           1        0.03           468        14.07
                     87855           1        0.03           469        14.10
                     87952           2        0.06           471        14.16
                     88059           2        0.06           473        14.22
                     88558           2        0.06           475        14.28
                     88652           1        0.03           476        14.31
                     88952           1        0.03           477        14.34
                     89659           1        0.03           478        14.37
                     89955           1        0.03           479        14.40
                     90054           2        0.06           481        14.46
                     90151           1        0.03           482        14.49
                     90651           1        0.03           483        14.52
                     90853           2        0.06           485        14.58
                     91157           1        0.03           486        14.61
                     91253           1        0.03           487        14.64
                     91353           1        0.03           488        14.67
                     91655           2        0.06           490        14.73
                     91760           1        0.03           491        14.76
                     91858           5        0.15           496        14.91
                     92053           1        0.03           497        14.94
                     92156           1        0.03           498        14.97
                     92157           3        0.09           501        15.06
                     92451           2        0.06           503        15.12
                     92659           1        0.03           504        15.15
                     92957           1        0.03           505        15.18
                     93154           1        0.03           506        15.21
                     93160           1        0.03           507        15.24
                     93660           1        0.03           508        15.27
                     93852           1        0.03           509        15.30

                                         The SAS System       19:10 Tuesday, March 31, 2020 1349

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                     94055           1        0.03           510        15.33
                     94057           2        0.06           512        15.39
                     94155           1        0.03           513        15.42
                     94354           1        0.03           514        15.45
                     94657           2        0.06           516        15.51
                     94759           2        0.06           518        15.57
                     94852           1        0.03           519        15.60
                     95051           1        0.03           520        15.63
                     95054           1        0.03           521        15.66
                     95453           1        0.03           522        15.69
                     95557           1        0.03           523        15.72
                     95859           1        0.03           524        15.75
                     95958           1        0.03           525        15.78
                     96252           2        0.06           527        15.84
                     96856           1        0.03           528        15.87
                     97151           1        0.03           529        15.90
                     97256           1        0.03           530        15.93
                     97554           1        0.03           531        15.96
                     97652           3        0.09           534        16.05
                     97656           1        0.03           535        16.08
                     97754           1        0.03           536        16.11
                     97758           1        0.03           537        16.14
                     98055           1        0.03           538        16.17
                     98158           1        0.03           539        16.20
                     99151           1        0.03           540        16.23
                     99155           1        0.03           541        16.26
                     99353           1        0.03           542        16.29
                     99960           2        0.06           544        16.35
                    100154           4        0.12           548        16.47
                    100251           1        0.03           549        16.50
                    100852           1        0.03           550        16.53
                    101152           2        0.06           552        16.59
                    101354           1        0.03           553        16.62
                    101359           1        0.03           554        16.65
                    101658           1        0.03           555        16.68
                    101659           1        0.03           556        16.71
                    102056           1        0.03           557        16.74
                    102160           1        0.03           558        16.77
                    102256           1        0.03           559        16.80
                    102356           1        0.03           560        16.83
                    102552           1        0.03           561        16.86
                    102756           1        0.03           562        16.89
                    102760           2        0.06           564        16.95
                    103256           1        0.03           565        16.98
                    103856           1        0.03           566        17.01
                    103953           1        0.03           567        17.04

                                         The SAS System       19:10 Tuesday, March 31, 2020 1350

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    104160           1        0.03           568        17.07
                    104755           1        0.03           569        17.10
                    105554           1        0.03           570        17.13
                    105955           1        0.03           571        17.16
                    106458           1        0.03           572        17.19
                    106657           2        0.06           574        17.25
                    106859           1        0.03           575        17.28
                    106960           1        0.03           576        17.31
                    107153           1        0.03           577        17.34
                    107553           1        0.03           578        17.37
                    108156           1        0.03           579        17.40
                    108260           1        0.03           580        17.43
                    108351           1        0.03           581        17.46
                    108555           1        0.03           582        17.49
                    108754           1        0.03           583        17.52
                    109053           1        0.03           584        17.55
                    109160           1        0.03           585        17.58
                    109254           2        0.06           587        17.64
                    109259           1        0.03           588        17.67
                    110556           1        0.03           589        17.70
                    110754           1        0.03           590        17.73
                    110759           2        0.06           592        17.79
                    110858           1        0.03           593        17.82
                    111351           1        0.03           594        17.85
                    111359           1        0.03           595        17.88
                    112052           2        0.06           597        17.94
                    112054           1        0.03           598        17.97
                    112060           1        0.03           599        18.00
                    112456           1        0.03           600        18.03
                    112655           1        0.03           601        18.06
                    112755           2        0.06           603        18.12
                    112760           1        0.03           604        18.15
                    113256           1        0.03           605        18.18
                    113353           1        0.03           606        18.21
                    113656           1        0.03           607        18.24
                    113659           1        0.03           608        18.27
                    113752           1        0.03           609        18.30
                    114658           1        0.03           610        18.33
                    115355           1        0.03           611        18.36
                    115751           1        0.03           612        18.39
                    115852           2        0.06           614        18.46
                    115853           1        0.03           615        18.49
                    115859           2        0.06           617        18.55
                    116055           1        0.03           618        18.58
                    116359           1        0.03           619        18.61
                    116557           1        0.03           620        18.64

                                         The SAS System       19:10 Tuesday, March 31, 2020 1351

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    116659           3        0.09           623        18.73
                    116752           2        0.06           625        18.79
                    116851           1        0.03           626        18.82
                    117253           1        0.03           627        18.85
                    117255           1        0.03           628        18.88
                    118859           2        0.06           630        18.94
                    119056           1        0.03           631        18.97
                    119253           1        0.03           632        19.00
                    119359           1        0.03           633        19.03
                    119558           1        0.03           634        19.06
                    119654           1        0.03           635        19.09
                    119660           1        0.03           636        19.12
                    120359           2        0.06           638        19.18
                    120453           2        0.06           640        19.24
                    121351           1        0.03           641        19.27
                    122053           1        0.03           642        19.30
                    122551           1        0.03           643        19.33
                    122555           2        0.06           645        19.39
                    122560           1        0.03           646        19.42
                    123257           1        0.03           647        19.45
                    123452           1        0.03           648        19.48
                    123454           1        0.03           649        19.51
                    123455           1        0.03           650        19.54
                    123656           2        0.06           652        19.60
                    123854           1        0.03           653        19.63
                    123858           1        0.03           654        19.66
                    123958           1        0.03           655        19.69
                    124153           2        0.06           657        19.75
                    124753           1        0.03           658        19.78
                    124955           1        0.03           659        19.81
                    125051           1        0.03           660        19.84
                    125056           1        0.03           661        19.87
                    125160           1        0.03           662        19.90
                    125351           1        0.03           663        19.93
                    125354           1        0.03           664        19.96
                    125451           1        0.03           665        19.99
                    125753           3        0.09           668        20.08
                    125758           1        0.03           669        20.11
                    125957           1        0.03           670        20.14
                    126060           1        0.03           671        20.17
                    126155           1        0.03           672        20.20
                    126156           1        0.03           673        20.23
                    126158           1        0.03           674        20.26
                    126655           1        0.03           675        20.29
                    126657           1        0.03           676        20.32
                    126857           1        0.03           677        20.35

                                         The SAS System       19:10 Tuesday, March 31, 2020 1352

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    127455           1        0.03           678        20.38
                    127656           1        0.03           679        20.41
                    127751           1        0.03           680        20.44
                    127860           1        0.03           681        20.47
                    127959           1        0.03           682        20.50
                    128156           1        0.03           683        20.53
                    128858           2        0.06           685        20.59
                    128958           1        0.03           686        20.62
                    129451           1        0.03           687        20.65
                    129554           2        0.06           689        20.71
                    129758           1        0.03           690        20.74
                    130155           1        0.03           691        20.77
                    130359           1        0.03           692        20.80
                    130957           1        0.03           693        20.83
                    131151           1        0.03           694        20.86
                    131854           1        0.03           695        20.89
                    132053           1        0.03           696        20.92
                    132160           1        0.03           697        20.95
                    133155           1        0.03           698        20.98
                    133456           1        0.03           699        21.01
                    133552           1        0.03           700        21.04
                    133558           3        0.09           703        21.13
                    133751           1        0.03           704        21.16
                    133752           1        0.03           705        21.19
                    133954           2        0.06           707        21.25
                    134051           1        0.03           708        21.28
                    134052           1        0.03           709        21.31
                    134158           1        0.03           710        21.34
                    134257           2        0.06           712        21.40
                    134751           1        0.03           713        21.43
                    134958           1        0.03           714        21.46
                    135052           2        0.06           716        21.52
                    135060           1        0.03           717        21.55
                    135256           5        0.15           722        21.70
                    135351           1        0.03           723        21.73
                    135558           1        0.03           724        21.76
                    136057           1        0.03           725        21.79
                    136256           1        0.03           726        21.82
                    136351           1        0.03           727        21.85
                    136353           1        0.03           728        21.88
                    136558           1        0.03           729        21.91
                    137052           2        0.06           731        21.97
                    137654           1        0.03           732        22.00
                    137756           1        0.03           733        22.03
                    137858           1        0.03           734        22.06
                    138254           1        0.03           735        22.09

                                         The SAS System       19:10 Tuesday, March 31, 2020 1353

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    138260           1        0.03           736        22.12
                    138454           1        0.03           737        22.15
                    138859           2        0.06           739        22.21
                    139859           1        0.03           740        22.24
                    140060           1        0.03           741        22.27
                    140160           1        0.03           742        22.30
                    140360           1        0.03           743        22.33
                    140554           1        0.03           744        22.36
                    140960           2        0.06           746        22.42
                    141451           1        0.03           747        22.45
                    141651           1        0.03           748        22.48
                    141656           1        0.03           749        22.51
                    142159           1        0.03           750        22.54
                    142355           1        0.03           751        22.57
                    142358           1        0.03           752        22.60
                    142360           1        0.03           753        22.63
                    142454           1        0.03           754        22.66
                    144055           1        0.03           755        22.69
                    144253           1        0.03           756        22.72
                    144751           1        0.03           757        22.75
                    144753           2        0.06           759        22.81
                    144758           1        0.03           760        22.84
                    144958           1        0.03           761        22.87
                    145059           3        0.09           764        22.96
                    145155           1        0.03           765        22.99
                    145253           1        0.03           766        23.02
                    145456           1        0.03           767        23.05
                    145654           1        0.03           768        23.08
                    145655           2        0.06           770        23.14
                    145752           1        0.03           771        23.17
                    145851           2        0.06           773        23.23
                    145860           2        0.06           775        23.29
                    146354           2        0.06           777        23.35
                    146457           1        0.03           778        23.38
                    146654           1        0.03           779        23.41
                    146755           1        0.03           780        23.44
                    146956           2        0.06           782        23.50
                    147154           1        0.03           783        23.53
                    147359           1        0.03           784        23.56
                    147756           1        0.03           785        23.59
                    147758           1        0.03           786        23.62
                    147858           1        0.03           787        23.65
                    148156           1        0.03           788        23.69
                    148256           1        0.03           789        23.72
                    148358           1        0.03           790        23.75
                    148359           1        0.03           791        23.78

                                         The SAS System       19:10 Tuesday, March 31, 2020 1354

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    148753           2        0.06           793        23.84
                    148951           1        0.03           794        23.87
                    148953           1        0.03           795        23.90
                    149553           2        0.06           797        23.96
                    149857           1        0.03           798        23.99
                    150051           1        0.03           799        24.02
                    150354           1        0.03           800        24.05
                    150455           1        0.03           801        24.08
                    150552           2        0.06           803        24.14
                    151653           1        0.03           804        24.17
                    152656           1        0.03           805        24.20
                    153754           2        0.06           807        24.26
                    153953           1        0.03           808        24.29
                    153956           1        0.03           809        24.32
                    154658           1        0.03           810        24.35
                    154660           1        0.03           811        24.38
                    155055           1        0.03           812        24.41
                    155258           1        0.03           813        24.44
                    155457           1        0.03           814        24.47
                    155560           1        0.03           815        24.50
                    156453           1        0.03           816        24.53
                    156551           1        0.03           817        24.56
                    156560           1        0.03           818        24.59
                    156658           1        0.03           819        24.62
                    156660           3        0.09           822        24.71
                    156853           1        0.03           823        24.74
                    156953           1        0.03           824        24.77
                    157058           1        0.03           825        24.80
                    157356           1        0.03           826        24.83
                    157951           1        0.03           827        24.86
                    157957           1        0.03           828        24.89
                    157958           1        0.03           829        24.92
                    158259           1        0.03           830        24.95
                    158358           2        0.06           832        25.01
                    158659           1        0.03           833        25.04
                    158856           1        0.03           834        25.07
                    158951           1        0.03           835        25.10
                    158958           1        0.03           836        25.13
                    159155           1        0.03           837        25.16
                    159356           1        0.03           838        25.19
                    159451           1        0.03           839        25.22
                    159852           1        0.03           840        25.25
                    159956           1        0.03           841        25.28
                    160657           1        0.03           842        25.31
                    160752           1        0.03           843        25.34
                    161154           1        0.03           844        25.37

                                         The SAS System       19:10 Tuesday, March 31, 2020 1355

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    161156           1        0.03           845        25.40
                    161459           2        0.06           847        25.46
                    161556           1        0.03           848        25.49
                    162054           2        0.06           850        25.55
                    162160           1        0.03           851        25.58
                    162258           1        0.03           852        25.61
                    162656           1        0.03           853        25.64
                    162759           1        0.03           854        25.67
                    163354           1        0.03           855        25.70
                    163551           1        0.03           856        25.73
                    163655           1        0.03           857        25.76
                    163657           1        0.03           858        25.79
                    164453           1        0.03           859        25.82
                    164651           1        0.03           860        25.85
                    164958           1        0.03           861        25.88
                    165160           2        0.06           863        25.94
                    165560           1        0.03           864        25.97
                    165857           1        0.03           865        26.00
                    165954           2        0.06           867        26.06
                    166359           1        0.03           868        26.09
                    166654           4        0.12           872        26.21
                    166851           1        0.03           873        26.24
                    166860           2        0.06           875        26.30
                    167152           1        0.03           876        26.33
                    167860           1        0.03           877        26.36
                    168560           1        0.03           878        26.39
                    168754           1        0.03           879        26.42
                    168852           1        0.03           880        26.45
                    168955           1        0.03           881        26.48
                    169260           1        0.03           882        26.51
                    169354           1        0.03           883        26.54
                    169852           1        0.03           884        26.57
                    170152           1        0.03           885        26.60
                    170856           1        0.03           886        26.63
                    171051           1        0.03           887        26.66
                    171251           1        0.03           888        26.69
                    171354           1        0.03           889        26.72
                    171558           1        0.03           890        26.75
                    171952           1        0.03           891        26.78
                    171959           2        0.06           893        26.84
                    172451           1        0.03           894        26.87
                    172956           1        0.03           895        26.90
                    173059           1        0.03           896        26.93
                    173352           2        0.06           898        26.99
                    173353           1        0.03           899        27.02
                    174253           1        0.03           900        27.05

                                         The SAS System       19:10 Tuesday, March 31, 2020 1356

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    174453           2        0.06           902        27.11
                    174757           1        0.03           903        27.14
                    175151           2        0.06           905        27.20
                    175152           2        0.06           907        27.26
                    175858           1        0.03           908        27.29
                    175960           1        0.03           909        27.32
                    176151           1        0.03           910        27.35
                    176154           1        0.03           911        27.38
                    176160           1        0.03           912        27.41
                    176257           1        0.03           913        27.44
                    176260           1        0.03           914        27.47
                    176454           1        0.03           915        27.50
                    176760           1        0.03           916        27.53
                    177056           2        0.06           918        27.59
                    177153           1        0.03           919        27.62
                    177357           2        0.06           921        27.68
                    177754           1        0.03           922        27.71
                    177757           1        0.03           923        27.74
                    177760           1        0.03           924        27.77
                    178051           1        0.03           925        27.80
                    178760           1        0.03           926        27.83
                    179452           1        0.03           927        27.86
                    179757           2        0.06           929        27.92
                    179856           1        0.03           930        27.95
                    179860           2        0.06           932        28.01
                    180557           1        0.03           933        28.04
                    180855           1        0.03           934        28.07
                    180856           2        0.06           936        28.13
                    181053           1        0.03           937        28.16
                    181159           1        0.03           938        28.19
                    181856           1        0.03           939        28.22
                    182153           1        0.03           940        28.25
                    182253           1        0.03           941        28.28
                    182255           2        0.06           943        28.34
                    182755           1        0.03           944        28.37
                    183052           1        0.03           945        28.40
                    183158           1        0.03           946        28.43
                    183352           1        0.03           947        28.46
                    183456           2        0.06           949        28.52
                    183551           1        0.03           950        28.55
                    183554           1        0.03           951        28.58
                    183760           1        0.03           952        28.61
                    184151           3        0.09           955        28.70
                    184354           1        0.03           956        28.73
                    184454           1        0.03           957        28.76
                    184754           2        0.06           959        28.82

                                         The SAS System       19:10 Tuesday, March 31, 2020 1357

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    184951           1        0.03           960        28.85
                    185255           1        0.03           961        28.88
                    185457           1        0.03           962        28.91
                    185653           1        0.03           963        28.94
                    185756           1        0.03           964        28.98
                    185758           1        0.03           965        29.01
                    186055           1        0.03           966        29.04
                    186153           2        0.06           968        29.10
                    186356           1        0.03           969        29.13
                    186553           1        0.03           970        29.16
                    186558           3        0.09           973        29.25
                    187052           1        0.03           974        29.28
                    187355           1        0.03           975        29.31
                    187653           2        0.06           977        29.37
                    187654           1        0.03           978        29.40
                    188058           1        0.03           979        29.43
                    188153           1        0.03           980        29.46
                    188359           3        0.09           983        29.55
                    188456           1        0.03           984        29.58
                    188459           1        0.03           985        29.61
                    188557           1        0.03           986        29.64
                    188558           2        0.06           988        29.70
                    188559           1        0.03           989        29.73
                    188560           1        0.03           990        29.76
                    188755           1        0.03           991        29.79
                    188955           1        0.03           992        29.82
                    189256           1        0.03           993        29.85
                    189260           1        0.03           994        29.88
                    189357           2        0.06           996        29.94
                    189758           2        0.06           998        30.00
                    189856           1        0.03           999        30.03
                    190054           1        0.03          1000        30.06
                    190360           1        0.03          1001        30.09
                    190656           1        0.03          1002        30.12
                    190657           2        0.06          1004        30.18
                    190860           1        0.03          1005        30.21
                    191252           1        0.03          1006        30.24
                    191257           1        0.03          1007        30.27
                    191556           2        0.06          1009        30.33
                    191755           2        0.06          1011        30.39
                    191856           1        0.03          1012        30.42
                    192451           1        0.03          1013        30.45
                    192551           1        0.03          1014        30.48
                    192556           1        0.03          1015        30.51
                    192753           1        0.03          1016        30.54
                    192854           2        0.06          1018        30.60

                                         The SAS System       19:10 Tuesday, March 31, 2020 1358

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    192855           1        0.03          1019        30.63
                    193054           1        0.03          1020        30.66
                    193158           1        0.03          1021        30.69
                    193254           1        0.03          1022        30.72
                    193657           1        0.03          1023        30.75
                    194353           1        0.03          1024        30.78
                    194459           3        0.09          1027        30.87
                    194552           1        0.03          1028        30.90
                    194852           2        0.06          1030        30.96
                    196454           2        0.06          1032        31.02
                    196460           2        0.06          1034        31.08
                    196855           1        0.03          1035        31.11
                    196857           1        0.03          1036        31.14
                    196959           1        0.03          1037        31.17
                    196960           1        0.03          1038        31.20
                    197052           1        0.03          1039        31.23
                    197460           1        0.03          1040        31.26
                    197652           1        0.03          1041        31.29
                    198055           1        0.03          1042        31.32
                    198259           2        0.06          1044        31.38
                    198452           1        0.03          1045        31.41
                    198556           2        0.06          1047        31.47
                    198651           1        0.03          1048        31.50
                    198655           1        0.03          1049        31.53
                    199455           1        0.03          1050        31.56
                    199551           1        0.03          1051        31.59
                    199554           1        0.03          1052        31.62
                    199557           1        0.03          1053        31.65
                    199760           1        0.03          1054        31.68
                    200158           1        0.03          1055        31.71
                    200656           2        0.06          1057        31.77
                    200754           2        0.06          1059        31.83
                    200755           1        0.03          1060        31.86
                    201559           1        0.03          1061        31.89
                    201755           1        0.03          1062        31.92
                    201758           1        0.03          1063        31.95
                    202151           1        0.03          1064        31.98
                    202251           1        0.03          1065        32.01
                    202360           3        0.09          1068        32.10
                    202656           1        0.03          1069        32.13
                    202751           1        0.03          1070        32.16
                    202856           1        0.03          1071        32.19
                    203156           1        0.03          1072        32.22
                    203558           1        0.03          1073        32.25
                    203651           2        0.06          1075        32.31
                    203660           1        0.03          1076        32.34

                                         The SAS System       19:10 Tuesday, March 31, 2020 1359

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    203851           1        0.03          1077        32.37
                    203855           1        0.03          1078        32.40
                    204058           1        0.03          1079        32.43
                    204255           1        0.03          1080        32.46
                    204955           1        0.03          1081        32.49
                    205856           1        0.03          1082        32.52
                    206155           2        0.06          1084        32.58
                    206958           1        0.03          1085        32.61
                    207153           1        0.03          1086        32.64
                    207452           1        0.03          1087        32.67
                    208154           1        0.03          1088        32.70
                    208257           1        0.03          1089        32.73
                    209452           1        0.03          1090        32.76
                    210355           1        0.03          1091        32.79
                    211260           1        0.03          1092        32.82
                    211657           2        0.06          1094        32.88
                    211755           1        0.03          1095        32.91
                    212353           1        0.03          1096        32.94
                    213052           1        0.03          1097        32.97
                    213351           2        0.06          1099        33.03
                    213457           1        0.03          1100        33.06
                    213554           2        0.06          1102        33.12
                    214060           1        0.03          1103        33.15
                    214358           1        0.03          1104        33.18
                    214460           1        0.03          1105        33.21
                    214851           1        0.03          1106        33.24
                    215156           1        0.03          1107        33.27
                    215353           1        0.03          1108        33.30
                    215453           1        0.03          1109        33.33
                    215459           2        0.06          1111        33.39
                    216056           2        0.06          1113        33.45
                    216652           1        0.03          1114        33.48
                    217052           1        0.03          1115        33.51
                    217251           1        0.03          1116        33.54
                    217559           1        0.03          1117        33.57
                    217652           1        0.03          1118        33.60
                    217656           1        0.03          1119        33.63
                    217758           2        0.06          1121        33.69
                    217760           1        0.03          1122        33.72
                    217952           1        0.03          1123        33.75
                    218155           1        0.03          1124        33.78
                    218159           1        0.03          1125        33.81
                    218953           1        0.03          1126        33.84
                    218958           2        0.06          1128        33.90
                    219259           1        0.03          1129        33.93
                    219353           1        0.03          1130        33.96

                                         The SAS System       19:10 Tuesday, March 31, 2020 1360

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    219552           1        0.03          1131        33.99
                    219556           1        0.03          1132        34.02
                    219558           1        0.03          1133        34.05
                    219659           1        0.03          1134        34.08
                    219660           1        0.03          1135        34.11
                    219754           1        0.03          1136        34.14
                    219756           1        0.03          1137        34.17
                    219958           1        0.03          1138        34.20
                    220653           1        0.03          1139        34.24
                    221659           1        0.03          1140        34.27
                    222952           1        0.03          1141        34.30
                    223059           1        0.03          1142        34.33
                    223160           1        0.03          1143        34.36
                    223354           1        0.03          1144        34.39
                    223457           1        0.03          1145        34.42
                    223559           1        0.03          1146        34.45
                    224659           1        0.03          1147        34.48
                    225259           1        0.03          1148        34.51
                    225455           2        0.06          1150        34.57
                    225458           1        0.03          1151        34.60
                    225459           1        0.03          1152        34.63
                    225752           1        0.03          1153        34.66
                    226351           2        0.06          1155        34.72
                    226555           1        0.03          1156        34.75
                    226859           1        0.03          1157        34.78
                    227160           1        0.03          1158        34.81
                    227552           1        0.03          1159        34.84
                    228057           1        0.03          1160        34.87
                    228453           1        0.03          1161        34.90
                    228460           1        0.03          1162        34.93
                    228660           1        0.03          1163        34.96
                    228855           1        0.03          1164        34.99
                    229259           1        0.03          1165        35.02
                    229860           2        0.06          1167        35.08
                    229959           1        0.03          1168        35.11
                    230152           1        0.03          1169        35.14
                    230454           1        0.03          1170        35.17
                    231259           1        0.03          1171        35.20
                    231953           1        0.03          1172        35.23
                    232152           1        0.03          1173        35.26
                    232359           1        0.03          1174        35.29
                    233553           1        0.03          1175        35.32
                    233753           2        0.06          1177        35.38
                    233951           2        0.06          1179        35.44
                    234359           1        0.03          1180        35.47
                    234453           2        0.06          1182        35.53

                                         The SAS System       19:10 Tuesday, March 31, 2020 1361

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    234651           1        0.03          1183        35.56
                    234756           1        0.03          1184        35.59
                    234852           1        0.03          1185        35.62
                    234857           1        0.03          1186        35.65
                    235054           1        0.03          1187        35.68
                    235254           1        0.03          1188        35.71
                    235657           1        0.03          1189        35.74
                    236055           4        0.12          1193        35.86
                    236057           1        0.03          1194        35.89
                    236160           1        0.03          1195        35.92
                    236257           1        0.03          1196        35.95
                    236357           4        0.12          1200        36.07
                    236455           2        0.06          1202        36.13
                    236552           1        0.03          1203        36.16
                    236759           1        0.03          1204        36.19
                    237053           3        0.09          1207        36.28
                    237557           1        0.03          1208        36.31
                    237952           1        0.03          1209        36.34
                    238060           1        0.03          1210        36.37
                    238557           1        0.03          1211        36.40
                    238654           1        0.03          1212        36.43
                    239255           1        0.03          1213        36.46
                    239354           1        0.03          1214        36.49
                    239451           1        0.03          1215        36.52
                    240054           1        0.03          1216        36.55
                    240251           1        0.03          1217        36.58
                    240358           1        0.03          1218        36.61
                    240458           1        0.03          1219        36.64
                    240752           1        0.03          1220        36.67
                    241253           1        0.03          1221        36.70
                    241652           2        0.06          1223        36.76
                    241754           1        0.03          1224        36.79
                    241956           1        0.03          1225        36.82
                    242260           1        0.03          1226        36.85
                    242353           1        0.03          1227        36.88
                    242355           6        0.18          1233        37.06
                    242358           1        0.03          1234        37.09
                    242555           1        0.03          1235        37.12
                    242655           1        0.03          1236        37.15
                    242759           1        0.03          1237        37.18
                    243160           1        0.03          1238        37.21
                    243252           1        0.03          1239        37.24
                    243555           2        0.06          1241        37.30
                    244051           1        0.03          1242        37.33
                    244951           1        0.03          1243        37.36
                    244955           1        0.03          1244        37.39

                                         The SAS System       19:10 Tuesday, March 31, 2020 1362

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    245158           1        0.03          1245        37.42
                    246060           1        0.03          1246        37.45
                    247058           2        0.06          1248        37.51
                    247457           2        0.06          1250        37.57
                    247752           2        0.06          1252        37.63
                    248255           1        0.03          1253        37.66
                    248660           1        0.03          1254        37.69
                    248759           1        0.03          1255        37.72
                    249152           1        0.03          1256        37.75
                    249159           1        0.03          1257        37.78
                    249354           1        0.03          1258        37.81
                    249456           1        0.03          1259        37.84
                    249960           1        0.03          1260        37.87
                    250056           1        0.03          1261        37.90
                    250554           2        0.06          1263        37.96
                    250555           1        0.03          1264        37.99
                    251052           1        0.03          1265        38.02
                    251458           1        0.03          1266        38.05
                    251654           1        0.03          1267        38.08
                    251753           2        0.06          1269        38.14
                    251957           1        0.03          1270        38.17
                    252458           2        0.06          1272        38.23
                    252556           1        0.03          1273        38.26
                    253454           1        0.03          1274        38.29
                    253456           1        0.03          1275        38.32
                    253660           1        0.03          1276        38.35
                    254053           2        0.06          1278        38.41
                    255051           1        0.03          1279        38.44
                    255151           1        0.03          1280        38.47
                    255156           1        0.03          1281        38.50
                    255259           1        0.03          1282        38.53
                    255552           2        0.06          1284        38.59
                    255754           1        0.03          1285        38.62
                    256058           1        0.03          1286        38.65
                    256556           1        0.03          1287        38.68
                    256560           1        0.03          1288        38.71
                    256660           1        0.03          1289        38.74
                    256753           1        0.03          1290        38.77
                    256756           1        0.03          1291        38.80
                    256951           1        0.03          1292        38.83
                    256952           1        0.03          1293        38.86
                    256953           1        0.03          1294        38.89
                    257258           1        0.03          1295        38.92
                    257452           1        0.03          1296        38.95
                    258154           1        0.03          1297        38.98
                    258655           1        0.03          1298        39.01

                                         The SAS System       19:10 Tuesday, March 31, 2020 1363

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    258755           1        0.03          1299        39.04
                    258854           1        0.03          1300        39.07
                    259551           1        0.03          1301        39.10
                    259554           1        0.03          1302        39.13
                    260552           1        0.03          1303        39.16
                    260558           1        0.03          1304        39.19
                    260652           1        0.03          1305        39.22
                    261753           1        0.03          1306        39.25
                    261755           1        0.03          1307        39.28
                    261852           1        0.03          1308        39.31
                    263359           1        0.03          1309        39.34
                    263752           2        0.06          1311        39.40
                    263755           1        0.03          1312        39.43
                    263956           1        0.03          1313        39.46
                    264154           2        0.06          1315        39.53
                    265055           1        0.03          1316        39.56
                    266356           1        0.03          1317        39.59
                    266658           1        0.03          1318        39.62
                    266851           1        0.03          1319        39.65
                    266856           1        0.03          1320        39.68
                    266960           1        0.03          1321        39.71
                    267152           1        0.03          1322        39.74
                    267451           1        0.03          1323        39.77
                    267556           1        0.03          1324        39.80
                    267654           1        0.03          1325        39.83
                    267958           1        0.03          1326        39.86
                    268353           1        0.03          1327        39.89
                    268752           2        0.06          1329        39.95
                    268754           1        0.03          1330        39.98
                    268859           1        0.03          1331        40.01
                    269252           1        0.03          1332        40.04
                    269454           1        0.03          1333        40.07
                    269557           1        0.03          1334        40.10
                    269652           1        0.03          1335        40.13
                    270651           1        0.03          1336        40.16
                    271553           1        0.03          1337        40.19
                    271557           1        0.03          1338        40.22
                    271753           1        0.03          1339        40.25
                    271954           1        0.03          1340        40.28
                    271956           5        0.15          1345        40.43
                    272055           1        0.03          1346        40.46
                    272158           1        0.03          1347        40.49
                    272258           1        0.03          1348        40.52
                    273054           1        0.03          1349        40.55
                    273852           1        0.03          1350        40.58
                    274459           1        0.03          1351        40.61

                                         The SAS System       19:10 Tuesday, March 31, 2020 1364

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    274955           3        0.09          1354        40.70
                    275460           2        0.06          1356        40.76
                    275852           1        0.03          1357        40.79
                    275959           1        0.03          1358        40.82
                    276156           2        0.06          1360        40.88
                    276460           1        0.03          1361        40.91
                    276952           1        0.03          1362        40.94
                    277058           1        0.03          1363        40.97
                    277259           1        0.03          1364        41.00
                    277555           1        0.03          1365        41.03
                    278056           1        0.03          1366        41.06
                    278151           2        0.06          1368        41.12
                    279251           2        0.06          1370        41.18
                    279352           1        0.03          1371        41.21
                    279452           1        0.03          1372        41.24
                    279558           1        0.03          1373        41.27
                    279660           1        0.03          1374        41.30
                    280060           3        0.09          1377        41.39
                    280555           1        0.03          1378        41.42
                    280752           1        0.03          1379        41.45
                    281158           1        0.03          1380        41.48
                    281260           1        0.03          1381        41.51
                    282059           1        0.03          1382        41.54
                    282257           1        0.03          1383        41.57
                    282351           1        0.03          1384        41.60
                    282754           1        0.03          1385        41.63
                    282855           1        0.03          1386        41.66
                    283152           1        0.03          1387        41.69
                    283551           1        0.03          1388        41.72
                    283860           1        0.03          1389        41.75
                    283951           1        0.03          1390        41.78
                    284153           1        0.03          1391        41.81
                    284558           1        0.03          1392        41.84
                    284658           1        0.03          1393        41.87
                    284957           3        0.09          1396        41.96
                    285054           1        0.03          1397        41.99
                    285057           1        0.03          1398        42.02
                    285554           2        0.06          1400        42.08
                    286157           1        0.03          1401        42.11
                    286456           1        0.03          1402        42.14
                    286954           1        0.03          1403        42.17
                    287154           1        0.03          1404        42.20
                    287358           1        0.03          1405        42.23
                    287559           1        0.03          1406        42.26
                    287652           1        0.03          1407        42.29
                    287660           1        0.03          1408        42.32

                                         The SAS System       19:10 Tuesday, March 31, 2020 1365

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    287855           1        0.03          1409        42.35
                    287951           1        0.03          1410        42.38
                    288053           1        0.03          1411        42.41
                    288154           1        0.03          1412        42.44
                    288554           1        0.03          1413        42.47
                    288955           1        0.03          1414        42.50
                    289054           1        0.03          1415        42.53
                    289652           1        0.03          1416        42.56
                    289656           1        0.03          1417        42.59
                    289751           1        0.03          1418        42.62
                    289760           1        0.03          1419        42.65
                    290051           1        0.03          1420        42.68
                    290156           1        0.03          1421        42.71
                    290158           1        0.03          1422        42.74
                    290251           1        0.03          1423        42.77
                    290254           1        0.03          1424        42.80
                    290260           1        0.03          1425        42.83
                    290758           1        0.03          1426        42.86
                    290855           1        0.03          1427        42.89
                    291454           1        0.03          1428        42.92
                    291458           2        0.06          1430        42.98
                    291559           2        0.06          1432        43.04
                    291758           1        0.03          1433        43.07
                    291857           1        0.03          1434        43.10
                    291955           1        0.03          1435        43.13
                    292351           1        0.03          1436        43.16
                    292557           3        0.09          1439        43.25
                    292753           1        0.03          1440        43.28
                    292759           1        0.03          1441        43.31
                    293457           4        0.12          1445        43.43
                    293552           1        0.03          1446        43.46
                    293752           2        0.06          1448        43.52
                    294060           1        0.03          1449        43.55
                    295754           1        0.03          1450        43.58
                    295958           1        0.03          1451        43.61
                    296054           2        0.06          1453        43.67
                    296556           1        0.03          1454        43.70
                    297155           1        0.03          1455        43.73
                    297159           1        0.03          1456        43.76
                    297252           1        0.03          1457        43.79
                    297360           1        0.03          1458        43.82
                    297551           1        0.03          1459        43.85
                    297952           1        0.03          1460        43.88
                    298056           2        0.06          1462        43.94
                    298157           1        0.03          1463        43.97
                    298860           1        0.03          1464        44.00

                                         The SAS System       19:10 Tuesday, March 31, 2020 1366

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    299656           1        0.03          1465        44.03
                    299757           1        0.03          1466        44.06
                    299854           2        0.06          1468        44.12
                    299855           1        0.03          1469        44.15
                    300355           1        0.03          1470        44.18
                    300460           2        0.06          1472        44.24
                    300559           2        0.06          1474        44.30
                    301157           1        0.03          1475        44.33
                    301853           1        0.03          1476        44.36
                    302254           1        0.03          1477        44.39
                    302358           1        0.03          1478        44.42
                    302453           1        0.03          1479        44.45
                    302553           1        0.03          1480        44.48
                    302760           1        0.03          1481        44.51
                    302860           1        0.03          1482        44.54
                    304155           1        0.03          1483        44.57
                    304357           1        0.03          1484        44.60
                    304855           1        0.03          1485        44.63
                    305359           1        0.03          1486        44.66
                    305653           1        0.03          1487        44.69
                    305655           1        0.03          1488        44.72
                    305953           1        0.03          1489        44.76
                    306059           1        0.03          1490        44.79
                    306151           1        0.03          1491        44.82
                    306159           1        0.03          1492        44.85
                    306160           1        0.03          1493        44.88
                    306959           1        0.03          1494        44.91
                    307059           1        0.03          1495        44.94
                    307254           1        0.03          1496        44.97
                    307260           1        0.03          1497        45.00
                    307553           1        0.03          1498        45.03
                    307860           1        0.03          1499        45.06
                    308956           1        0.03          1500        45.09
                    309151           1        0.03          1501        45.12
                    309354           1        0.03          1502        45.15
                    309557           1        0.03          1503        45.18
                    309558           1        0.03          1504        45.21
                    309657           1        0.03          1505        45.24
                    309857           1        0.03          1506        45.27
                    310051           1        0.03          1507        45.30
                    310054           1        0.03          1508        45.33
                    310254           1        0.03          1509        45.36
                    310552           1        0.03          1510        45.39
                    311356           2        0.06          1512        45.45
                    311359           1        0.03          1513        45.48
                    311752           1        0.03          1514        45.51

                                         The SAS System       19:10 Tuesday, March 31, 2020 1367

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    312756           1        0.03          1515        45.54
                    313359           2        0.06          1517        45.60
                    314556           1        0.03          1518        45.63
                    314753           1        0.03          1519        45.66
                    314854           1        0.03          1520        45.69
                    315660           1        0.03          1521        45.72
                    315755           1        0.03          1522        45.75
                    315859           1        0.03          1523        45.78
                    316351           1        0.03          1524        45.81
                    316352           1        0.03          1525        45.84
                    316855           1        0.03          1526        45.87
                    317052           1        0.03          1527        45.90
                    317054           1        0.03          1528        45.93
                    317160           1        0.03          1529        45.96
                    317258           1        0.03          1530        45.99
                    317559           1        0.03          1531        46.02
                    317858           1        0.03          1532        46.05
                    317859           1        0.03          1533        46.08
                    319052           1        0.03          1534        46.11
                    319254           1        0.03          1535        46.14
                    319657           1        0.03          1536        46.17
                    320860           1        0.03          1537        46.20
                    320960           1        0.03          1538        46.23
                    321058           1        0.03          1539        46.26
                    321455           1        0.03          1540        46.29
                    322259           1        0.03          1541        46.32
                    322260           1        0.03          1542        46.35
                    322858           1        0.03          1543        46.38
                    322957           2        0.06          1545        46.44
                    323153           1        0.03          1546        46.47
                    323159           1        0.03          1547        46.50
                    323357           1        0.03          1548        46.53
                    323453           1        0.03          1549        46.56
                    323755           1        0.03          1550        46.59
                    323959           1        0.03          1551        46.62
                    324055           1        0.03          1552        46.65
                    324454           1        0.03          1553        46.68
                    324551           1        0.03          1554        46.71
                    324952           1        0.03          1555        46.74
                    325157           1        0.03          1556        46.77
                    325353           1        0.03          1557        46.80
                    325654           1        0.03          1558        46.83
                    326352           1        0.03          1559        46.86
                    326455           1        0.03          1560        46.89
                    326958           1        0.03          1561        46.92
                    326960           1        0.03          1562        46.95

                                         The SAS System       19:10 Tuesday, March 31, 2020 1368

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    327253           1        0.03          1563        46.98
                    327255           1        0.03          1564        47.01
                    327260           1        0.03          1565        47.04
                    328257           1        0.03          1566        47.07
                    328554           1        0.03          1567        47.10
                    328760           1        0.03          1568        47.13
                    328957           1        0.03          1569        47.16
                    329552           1        0.03          1570        47.19
                    329856           1        0.03          1571        47.22
                    330055           1        0.03          1572        47.25
                    330058           1        0.03          1573        47.28
                    330158           1        0.03          1574        47.31
                    330753           2        0.06          1576        47.37
                    331156           1        0.03          1577        47.40
                    331251           1        0.03          1578        47.43
                    331258           2        0.06          1580        47.49
                    331351           1        0.03          1581        47.52
                    331458           1        0.03          1582        47.55
                    332453           1        0.03          1583        47.58
                    333354           1        0.03          1584        47.61
                    333754           1        0.03          1585        47.64
                    334251           1        0.03          1586        47.67
                    334356           1        0.03          1587        47.70
                    334657           1        0.03          1588        47.73
                    334759           1        0.03          1589        47.76
                    334854           1        0.03          1590        47.79
                    335551           1        0.03          1591        47.82
                    335952           1        0.03          1592        47.85
                    335958           1        0.03          1593        47.88
                    336155           1        0.03          1594        47.91
                    336351           1        0.03          1595        47.94
                    336352           1        0.03          1596        47.97
                    336651           1        0.03          1597        48.00
                    337051           1        0.03          1598        48.03
                    337456           1        0.03          1599        48.06
                    337653           1        0.03          1600        48.09
                    337754           1        0.03          1601        48.12
                    337954           1        0.03          1602        48.15
                    338560           1        0.03          1603        48.18
                    338655           1        0.03          1604        48.21
                    339153           1        0.03          1605        48.24
                    339756           2        0.06          1607        48.30
                    340256           1        0.03          1608        48.33
                    340757           2        0.06          1610        48.39
                    341559           1        0.03          1611        48.42
                    341753           4        0.12          1615        48.54

                                         The SAS System       19:10 Tuesday, March 31, 2020 1369

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    341755           1        0.03          1616        48.57
                    342751           1        0.03          1617        48.60
                    342858           1        0.03          1618        48.63
                    343556           1        0.03          1619        48.66
                    344353           1        0.03          1620        48.69
                    345356           1        0.03          1621        48.72
                    345358           1        0.03          1622        48.75
                    345658           1        0.03          1623        48.78
                    345851           1        0.03          1624        48.81
                    346059           1        0.03          1625        48.84
                    346156           1        0.03          1626        48.87
                    346551           1        0.03          1627        48.90
                    346552           1        0.03          1628        48.93
                    346859           1        0.03          1629        48.96
                    347154           2        0.06          1631        49.02
                    347253           1        0.03          1632        49.05
                    347651           1        0.03          1633        49.08
                    347654           1        0.03          1634        49.11
                    347758           1        0.03          1635        49.14
                    347855           1        0.03          1636        49.17
                    348354           1        0.03          1637        49.20
                    348655           1        0.03          1638        49.23
                    348658           1        0.03          1639        49.26
                    348952           1        0.03          1640        49.29
                    348955           1        0.03          1641        49.32
                    349151           1        0.03          1642        49.35
                    349256           1        0.03          1643        49.38
                    349357           1        0.03          1644        49.41
                    349452           1        0.03          1645        49.44
                    349952           1        0.03          1646        49.47
                    350159           1        0.03          1647        49.50
                    350353           1        0.03          1648        49.53
                    350458           1        0.03          1649        49.56
                    351253           2        0.06          1651        49.62
                    351258           1        0.03          1652        49.65
                    351851           1        0.03          1653        49.68
                    351860           1        0.03          1654        49.71
                    352158           1        0.03          1655        49.74
                    352357           1        0.03          1656        49.77
                    352657           1        0.03          1657        49.80
                    352659           1        0.03          1658        49.83
                    352854           1        0.03          1659        49.86
                    353552           1        0.03          1660        49.89
                    353658           1        0.03          1661        49.92
                    353959           2        0.06          1663        49.98
                    354453           1        0.03          1664        50.02

                                         The SAS System       19:10 Tuesday, March 31, 2020 1370

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    354655           1        0.03          1665        50.05
                    354955           1        0.03          1666        50.08
                    355158           2        0.06          1668        50.14
                    355352           1        0.03          1669        50.17
                    355353           1        0.03          1670        50.20
                    355456           2        0.06          1672        50.26
                    356660           1        0.03          1673        50.29
                    357657           1        0.03          1674        50.32
                    357754           1        0.03          1675        50.35
                    358157           1        0.03          1676        50.38
                    358360           1        0.03          1677        50.41
                    358657           1        0.03          1678        50.44
                    358659           1        0.03          1679        50.47
                    358960           1        0.03          1680        50.50
                    359255           1        0.03          1681        50.53
                    359660           1        0.03          1682        50.56
                    360054           2        0.06          1684        50.62
                    360251           1        0.03          1685        50.65
                    360260           1        0.03          1686        50.68
                    360360           1        0.03          1687        50.71
                    360453           2        0.06          1689        50.77
                    360651           1        0.03          1690        50.80
                    360654           1        0.03          1691        50.83
                    360755           1        0.03          1692        50.86
                    360854           1        0.03          1693        50.89
                    360958           1        0.03          1694        50.92
                    361151           1        0.03          1695        50.95
                    361557           1        0.03          1696        50.98
                    361852           1        0.03          1697        51.01
                    362756           1        0.03          1698        51.04
                    362860           1        0.03          1699        51.07
                    363056           1        0.03          1700        51.10
                    363058           1        0.03          1701        51.13
                    363552           1        0.03          1702        51.16
                    363652           1        0.03          1703        51.19
                    363856           2        0.06          1705        51.25
                    364151           1        0.03          1706        51.28
                    364260           2        0.06          1708        51.34
                    364656           1        0.03          1709        51.37
                    364851           1        0.03          1710        51.40
                    364856           2        0.06          1712        51.46
                    365053           1        0.03          1713        51.49
                    365358           1        0.03          1714        51.52
                    365860           1        0.03          1715        51.55
                    366255           1        0.03          1716        51.58
                    366955           2        0.06          1718        51.64

                                         The SAS System       19:10 Tuesday, March 31, 2020 1371

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    367355           1        0.03          1719        51.67
                    367655           1        0.03          1720        51.70
                    368253           1        0.03          1721        51.73
                    368258           1        0.03          1722        51.76
                    368651           1        0.03          1723        51.79
                    368656           1        0.03          1724        51.82
                    369258           1        0.03          1725        51.85
                    369457           2        0.06          1727        51.91
                    369752           1        0.03          1728        51.94
                    369953           1        0.03          1729        51.97
                    369958           2        0.06          1731        52.03
                    370057           1        0.03          1732        52.06
                    370153           1        0.03          1733        52.09
                    370654           1        0.03          1734        52.12
                    370657           1        0.03          1735        52.15
                    370756           1        0.03          1736        52.18
                    370852           1        0.03          1737        52.21
                    372054           1        0.03          1738        52.24
                    372653           1        0.03          1739        52.27
                    372755           1        0.03          1740        52.30
                    372860           2        0.06          1742        52.36
                    373456           1        0.03          1743        52.39
                    373652           1        0.03          1744        52.42
                    373853           1        0.03          1745        52.45
                    374156           1        0.03          1746        52.48
                    374460           1        0.03          1747        52.51
                    375255           1        0.03          1748        52.54
                    375351           1        0.03          1749        52.57
                    375852           1        0.03          1750        52.60
                    376254           1        0.03          1751        52.63
                    376653           1        0.03          1752        52.66
                    376959           1        0.03          1753        52.69
                    377160           1        0.03          1754        52.72
                    377256           1        0.03          1755        52.75
                    378154           1        0.03          1756        52.78
                    378453           1        0.03          1757        52.81
                    378857           1        0.03          1758        52.84
                    378959           1        0.03          1759        52.87
                    379055           1        0.03          1760        52.90
                    379060           1        0.03          1761        52.93
                    379458           1        0.03          1762        52.96
                    380154           1        0.03          1763        52.99
                    380156           1        0.03          1764        53.02
                    380353           2        0.06          1766        53.08
                    380652           1        0.03          1767        53.11
                    380853           1        0.03          1768        53.14

                                         The SAS System       19:10 Tuesday, March 31, 2020 1372

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    381353           1        0.03          1769        53.17
                    381652           1        0.03          1770        53.20
                    382056           1        0.03          1771        53.23
                    382359           1        0.03          1772        53.26
                    382957           1        0.03          1773        53.29
                    382960           1        0.03          1774        53.32
                    383059           1        0.03          1775        53.35
                    383255           1        0.03          1776        53.38
                    383355           1        0.03          1777        53.41
                    383652           1        0.03          1778        53.44
                    383752           1        0.03          1779        53.47
                    384155           1        0.03          1780        53.50
                    384452           2        0.06          1782        53.56
                    384654           1        0.03          1783        53.59
                    385053           1        0.03          1784        53.62
                    385155           1        0.03          1785        53.65
                    385359           1        0.03          1786        53.68
                    385659           1        0.03          1787        53.71
                    385856           1        0.03          1788        53.74
                    385858           2        0.06          1790        53.80
                    386554           1        0.03          1791        53.83
                    386651           1        0.03          1792        53.86
                    386753           1        0.03          1793        53.89
                    386859           1        0.03          1794        53.92
                    387060           1        0.03          1795        53.95
                    387556           1        0.03          1796        53.98
                    388653           1        0.03          1797        54.01
                    388658           1        0.03          1798        54.04
                    389455           1        0.03          1799        54.07
                    389457           1        0.03          1800        54.10
                    389652           1        0.03          1801        54.13
                    389657           1        0.03          1802        54.16
                    389759           1        0.03          1803        54.19
                    390057           1        0.03          1804        54.22
                    390351           2        0.06          1806        54.28
                    390753           1        0.03          1807        54.31
                    391058           1        0.03          1808        54.34
                    391759           1        0.03          1809        54.37
                    391857           1        0.03          1810        54.40
                    392256           1        0.03          1811        54.43
                    392851           1        0.03          1812        54.46
                    392954           1        0.03          1813        54.49
                    393158           1        0.03          1814        54.52
                    393160           1        0.03          1815        54.55
                    393860           1        0.03          1816        54.58
                    393952           1        0.03          1817        54.61

                                         The SAS System       19:10 Tuesday, March 31, 2020 1373

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    394052           1        0.03          1818        54.64
                    394057           1        0.03          1819        54.67
                    394553           1        0.03          1820        54.70
                    394658           1        0.03          1821        54.73
                    394960           1        0.03          1822        54.76
                    395352           2        0.06          1824        54.82
                    395655           1        0.03          1825        54.85
                    395657           1        0.03          1826        54.88
                    396153           1        0.03          1827        54.91
                    396458           1        0.03          1828        54.94
                    397458           1        0.03          1829        54.97
                    397552           1        0.03          1830        55.00
                    397660           1        0.03          1831        55.03
                    398360           1        0.03          1832        55.06
                    398956           1        0.03          1833        55.09
                    398957           1        0.03          1834        55.12
                    399258           2        0.06          1836        55.18
                    399455           2        0.06          1838        55.24
                    399458           1        0.03          1839        55.28
                    399654           1        0.03          1840        55.31
                    400451           1        0.03          1841        55.34
                    400460           1        0.03          1842        55.37
                    400556           1        0.03          1843        55.40
                    400758           1        0.03          1844        55.43
                    400854           1        0.03          1845        55.46
                    401154           1        0.03          1846        55.49
                    401253           1        0.03          1847        55.52
                    401558           1        0.03          1848        55.55
                    401654           1        0.03          1849        55.58
                    401852           1        0.03          1850        55.61
                    401952           1        0.03          1851        55.64
                    402060           1        0.03          1852        55.67
                    402352           1        0.03          1853        55.70
                    402459           1        0.03          1854        55.73
                    402651           1        0.03          1855        55.76
                    402654           1        0.03          1856        55.79
                    402751           1        0.03          1857        55.82
                    402756           1        0.03          1858        55.85
                    402854           2        0.06          1860        55.91
                    403060           2        0.06          1862        55.97
                    403154           1        0.03          1863        56.00
                    403253           2        0.06          1865        56.06
                    403356           1        0.03          1866        56.09
                    403451           1        0.03          1867        56.12
                    403554           1        0.03          1868        56.15
                    403952           1        0.03          1869        56.18

                                         The SAS System       19:10 Tuesday, March 31, 2020 1374

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    404055           1        0.03          1870        56.21
                    404056           1        0.03          1871        56.24
                    404257           1        0.03          1872        56.27
                    404259           1        0.03          1873        56.30
                    404354           1        0.03          1874        56.33
                    404460           1        0.03          1875        56.36
                    404556           1        0.03          1876        56.39
                    404558           1        0.03          1877        56.42
                    404752           2        0.06          1879        56.48
                    404856           1        0.03          1880        56.51
                    405052           1        0.03          1881        56.54
                    405053           1        0.03          1882        56.57
                    405351           3        0.09          1885        56.66
                    405352           1        0.03          1886        56.69
                    405953           1        0.03          1887        56.72
                    406454           3        0.09          1890        56.81
                    406960           2        0.06          1892        56.87
                    407260           1        0.03          1893        56.90
                    407359           1        0.03          1894        56.93
                    407452           1        0.03          1895        56.96
                    407456           1        0.03          1896        56.99
                    408255           2        0.06          1898        57.05
                    408755           1        0.03          1899        57.08
                    409160           1        0.03          1900        57.11
                    409759           3        0.09          1903        57.20
                    409854           1        0.03          1904        57.23
                    410260           1        0.03          1905        57.26
                    410452           1        0.03          1906        57.29
                    410457           1        0.03          1907        57.32
                    411260           1        0.03          1908        57.35
                    411756           1        0.03          1909        57.38
                    411851           2        0.06          1911        57.44
                    412358           1        0.03          1912        57.47
                    412453           3        0.09          1915        57.56
                    412854           1        0.03          1916        57.59
                    413355           1        0.03          1917        57.62
                    413555           1        0.03          1918        57.65
                    414056           2        0.06          1920        57.71
                    414255           1        0.03          1921        57.74
                    414355           1        0.03          1922        57.77
                    414860           1        0.03          1923        57.80
                    415353           1        0.03          1924        57.83
                    415555           1        0.03          1925        57.86
                    415854           1        0.03          1926        57.89
                    415857           1        0.03          1927        57.92
                    415955           1        0.03          1928        57.95

                                         The SAS System       19:10 Tuesday, March 31, 2020 1375

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    416052           1        0.03          1929        57.98
                    416059           2        0.06          1931        58.04
                    416260           1        0.03          1932        58.07
                    416859           1        0.03          1933        58.10
                    417453           1        0.03          1934        58.13
                    417558           1        0.03          1935        58.16
                    417656           2        0.06          1937        58.22
                    417854           1        0.03          1938        58.25
                    417952           1        0.03          1939        58.28
                    417954           1        0.03          1940        58.31
                    417959           1        0.03          1941        58.34
                    418051           1        0.03          1942        58.37
                    418153           2        0.06          1944        58.43
                    418154           1        0.03          1945        58.46
                    418553           4        0.12          1949        58.58
                    418557           1        0.03          1950        58.61
                    418756           1        0.03          1951        58.64
                    418856           1        0.03          1952        58.67
                    419153           1        0.03          1953        58.70
                    419454           1        0.03          1954        58.73
                    419556           1        0.03          1955        58.76
                    419659           1        0.03          1956        58.79
                    419753           1        0.03          1957        58.82
                    419857           1        0.03          1958        58.85
                    419859           1        0.03          1959        58.88
                    420057           1        0.03          1960        58.91
                    420059           1        0.03          1961        58.94
                    420460           1        0.03          1962        58.97
                    420558           2        0.06          1964        59.03
                    420652           1        0.03          1965        59.06
                    420751           1        0.03          1966        59.09
                    420860           1        0.03          1967        59.12
                    420960           1        0.03          1968        59.15
                    421158           1        0.03          1969        59.18
                    421953           1        0.03          1970        59.21
                    421955           1        0.03          1971        59.24
                    423152           1        0.03          1972        59.27
                    423158           1        0.03          1973        59.30
                    423159           1        0.03          1974        59.33
                    423360           1        0.03          1975        59.36
                    425051           1        0.03          1976        59.39
                    425055           1        0.03          1977        59.42
                    425558           3        0.09          1980        59.51
                    425754           1        0.03          1981        59.54
                    426054           1        0.03          1982        59.57
                    426057           2        0.06          1984        59.63

                                         The SAS System       19:10 Tuesday, March 31, 2020 1376

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    426253           1        0.03          1985        59.66
                    426456           1        0.03          1986        59.69
                    427852           1        0.03          1987        59.72
                    427954           1        0.03          1988        59.75
                    428155           1        0.03          1989        59.78
                    429055           1        0.03          1990        59.81
                    429159           1        0.03          1991        59.84
                    429356           1        0.03          1992        59.87
                    429953           1        0.03          1993        59.90
                    430655           2        0.06          1995        59.96
                    430959           1        0.03          1996        59.99
                    431151           3        0.09          1999        60.08
                    431154           2        0.06          2001        60.14
                    431354           1        0.03          2002        60.17
                    431556           2        0.06          2004        60.23
                    431653           2        0.06          2006        60.29
                    431756           1        0.03          2007        60.32
                    431854           2        0.06          2009        60.38
                    431858           1        0.03          2010        60.41
                    432059           1        0.03          2011        60.44
                    432260           1        0.03          2012        60.47
                    433452           2        0.06          2014        60.54
                    434760           1        0.03          2015        60.57
                    435153           1        0.03          2016        60.60
                    436256           1        0.03          2017        60.63
                    437654           1        0.03          2018        60.66
                    437657           1        0.03          2019        60.69
                    437760           1        0.03          2020        60.72
                    440352           1        0.03          2021        60.75
                    441258           1        0.03          2022        60.78
                    442755           1        0.03          2023        60.81
                    442855           1        0.03          2024        60.84
                    443360           1        0.03          2025        60.87
                    443952           1        0.03          2026        60.90
                    444557           1        0.03          2027        60.93
                    444653           1        0.03          2028        60.96
                    445053           1        0.03          2029        60.99
                    445353           1        0.03          2030        61.02
                    445459           1        0.03          2031        61.05
                    445659           1        0.03          2032        61.08
                    445854           1        0.03          2033        61.11
                    445954           1        0.03          2034        61.14
                    446259           1        0.03          2035        61.17
                    446651           1        0.03          2036        61.20
                    446658           1        0.03          2037        61.23
                    447056           1        0.03          2038        61.26

                                         The SAS System       19:10 Tuesday, March 31, 2020 1377

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    447254           1        0.03          2039        61.29
                    447560           2        0.06          2041        61.35
                    448856           1        0.03          2042        61.38
                    449154           1        0.03          2043        61.41
                    449856           1        0.03          2044        61.44
                    450057           2        0.06          2046        61.50
                    450759           1        0.03          2047        61.53
                    451260           1        0.03          2048        61.56
                    451753           1        0.03          2049        61.59
                    452958           1        0.03          2050        61.62
                    453157           1        0.03          2051        61.65
                    453456           1        0.03          2052        61.68
                    453655           1        0.03          2053        61.71
                    453752           1        0.03          2054        61.74
                    453858           1        0.03          2055        61.77
                    453958           1        0.03          2056        61.80
                    453960           1        0.03          2057        61.83
                    454360           2        0.06          2059        61.89
                    455559           1        0.03          2060        61.92
                    455657           1        0.03          2061        61.95
                    456052           1        0.03          2062        61.98
                    456851           1        0.03          2063        62.01
                    457056           2        0.06          2065        62.07
                    457155           1        0.03          2066        62.10
                    457255           1        0.03          2067        62.13
                    457454           1        0.03          2068        62.16
                    457460           2        0.06          2070        62.22
                    457653           1        0.03          2071        62.25
                    457654           1        0.03          2072        62.28
                    458057           1        0.03          2073        62.31
                    458454           1        0.03          2074        62.34
                    459454           1        0.03          2075        62.37
                    459459           1        0.03          2076        62.40
                    459752           1        0.03          2077        62.43
                    459760           1        0.03          2078        62.46
                    459858           1        0.03          2079        62.49
                    459954           1        0.03          2080        62.52
                    460057           1        0.03          2081        62.55
                    460354           1        0.03          2082        62.58
                    460454           1        0.03          2083        62.61
                    460459           1        0.03          2084        62.64
                    460856           1        0.03          2085        62.67
                    461156           1        0.03          2086        62.70
                    461158           1        0.03          2087        62.73
                    462258           1        0.03          2088        62.76
                    462260           1        0.03          2089        62.79

                                         The SAS System       19:10 Tuesday, March 31, 2020 1378

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    463053           1        0.03          2090        62.82
                    463151           1        0.03          2091        62.85
                    463359           1        0.03          2092        62.88
                    463455           1        0.03          2093        62.91
                    463660           1        0.03          2094        62.94
                    463756           1        0.03          2095        62.97
                    464059           1        0.03          2096        63.00
                    464355           1        0.03          2097        63.03
                    464655           1        0.03          2098        63.06
                    465354           1        0.03          2099        63.09
                    466451           1        0.03          2100        63.12
                    466551           2        0.06          2102        63.18
                    467054           2        0.06          2104        63.24
                    467056           1        0.03          2105        63.27
                    467057           1        0.03          2106        63.30
                    468352           1        0.03          2107        63.33
                    468555           1        0.03          2108        63.36
                    468556           1        0.03          2109        63.39
                    469053           1        0.03          2110        63.42
                    469653           1        0.03          2111        63.45
                    470156           1        0.03          2112        63.48
                    470659           1        0.03          2113        63.51
                    470855           2        0.06          2115        63.57
                    470958           1        0.03          2116        63.60
                    471252           1        0.03          2117        63.63
                    471556           1        0.03          2118        63.66
                    472059           1        0.03          2119        63.69
                    473153           1        0.03          2120        63.72
                    473656           1        0.03          2121        63.75
                    474458           1        0.03          2122        63.78
                    475251           2        0.06          2124        63.84
                    475752           1        0.03          2125        63.87
                    475852           2        0.06          2127        63.93
                    476455           1        0.03          2128        63.96
                    476556           1        0.03          2129        63.99
                    477352           1        0.03          2130        64.02
                    477356           1        0.03          2131        64.05
                    477658           1        0.03          2132        64.08
                    478352           1        0.03          2133        64.11
                    478554           1        0.03          2134        64.14
                    478559           1        0.03          2135        64.17
                    478954           1        0.03          2136        64.20
                    478957           1        0.03          2137        64.23
                    479254           1        0.03          2138        64.26
                    479351           1        0.03          2139        64.29
                    479753           1        0.03          2140        64.32

                                         The SAS System       19:10 Tuesday, March 31, 2020 1379

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    480154           1        0.03          2141        64.35
                    480355           1        0.03          2142        64.38
                    480856           1        0.03          2143        64.41
                    481059           1        0.03          2144        64.44
                    481451           1        0.03          2145        64.47
                    481657           1        0.03          2146        64.50
                    481856           1        0.03          2147        64.53
                    482252           1        0.03          2148        64.56
                    482359           1        0.03          2149        64.59
                    482658           1        0.03          2150        64.62
                    482959           1        0.03          2151        64.65
                    484151           1        0.03          2152        64.68
                    484558           1        0.03          2153        64.71
                    485056           1        0.03          2154        64.74
                    485258           1        0.03          2155        64.77
                    485654           1        0.03          2156        64.80
                    485658           1        0.03          2157        64.83
                    486055           1        0.03          2158        64.86
                    486552           1        0.03          2159        64.89
                    486654           2        0.06          2161        64.95
                    487152           1        0.03          2162        64.98
                    487159           1        0.03          2163        65.01
                    487552           1        0.03          2164        65.04
                    487858           1        0.03          2165        65.07
                    488058           2        0.06          2167        65.13
                    488753           1        0.03          2168        65.16
                    489451           1        0.03          2169        65.19
                    489556           1        0.03          2170        65.22
                    489851           1        0.03          2171        65.25
                    490353           3        0.09          2174        65.34
                    490656           1        0.03          2175        65.37
                    491453           2        0.06          2177        65.43
                    491758           1        0.03          2178        65.46
                    492060           1        0.03          2179        65.49
                    492157           1        0.03          2180        65.52
                    492260           1        0.03          2181        65.55
                    492356           1        0.03          2182        65.58
                    492552           1        0.03          2183        65.61
                    493258           1        0.03          2184        65.64
                    493559           1        0.03          2185        65.67
                    493658           1        0.03          2186        65.70
                    493959           1        0.03          2187        65.73
                    494654           1        0.03          2188        65.76
                    494756           1        0.03          2189        65.80
                    494854           1        0.03          2190        65.83
                    494953           1        0.03          2191        65.86

                                         The SAS System       19:10 Tuesday, March 31, 2020 1380

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    495059           1        0.03          2192        65.89
                    495151           1        0.03          2193        65.92
                    498658           1        0.03          2194        65.95
                    508757           1        0.03          2195        65.98
                    508856           1        0.03          2196        66.01
                    509158           1        0.03          2197        66.04
                    511458           1        0.03          2198        66.07
                    512058           1        0.03          2199        66.10
                    513160           1        0.03          2200        66.13
                    513254           1        0.03          2201        66.16
                    513855           1        0.03          2202        66.19
                    514356           1        0.03          2203        66.22
                    517360           2        0.06          2205        66.28
                    517860           1        0.03          2206        66.31
                    517954           1        0.03          2207        66.34
                    518059           1        0.03          2208        66.37
                    519958           1        0.03          2209        66.40
                    519959           1        0.03          2210        66.43
                    522455           1        0.03          2211        66.46
                    523954           1        0.03          2212        66.49
                    524652           1        0.03          2213        66.52
                    525955           1        0.03          2214        66.55
                    530660           1        0.03          2215        66.58
                    530859           1        0.03          2216        66.61
                    531957           3        0.09          2219        66.70
                    533351           1        0.03          2220        66.73
                    534459           3        0.09          2223        66.82
                    536557           1        0.03          2224        66.85
                    539060           1        0.03          2225        66.88
                    539352           1        0.03          2226        66.91
                    540260           1        0.03          2227        66.94
                    540552           1        0.03          2228        66.97
                    540754           1        0.03          2229        67.00
                    540953           1        0.03          2230        67.03
                    541854           1        0.03          2231        67.06
                    542358           1        0.03          2232        67.09
                    545658           1        0.03          2233        67.12
                    546055           1        0.03          2234        67.15
                    547451           1        0.03          2235        67.18
                    555954           1        0.03          2236        67.21
                    557355           1        0.03          2237        67.24
                    558156           1        0.03          2238        67.27
                    560154           1        0.03          2239        67.30
                    561260           1        0.03          2240        67.33
                    562056           1        0.03          2241        67.36
                    562460           1        0.03          2242        67.39

                                         The SAS System       19:10 Tuesday, March 31, 2020 1381

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    563660           1        0.03          2243        67.42
                    563854           1        0.03          2244        67.45
                    564153           1        0.03          2245        67.48
                    564452           1        0.03          2246        67.51
                    565351           1        0.03          2247        67.54
                    566152           1        0.03          2248        67.57
                    568758           1        0.03          2249        67.60
                    569352           1        0.03          2250        67.63
                    569555           1        0.03          2251        67.66
                    570653           1        0.03          2252        67.69
                    571852           1        0.03          2253        67.72
                    573157           1        0.03          2254        67.75
                    574051           1        0.03          2255        67.78
                    577851           1        0.03          2256        67.81
                    579559           1        0.03          2257        67.84
                    580859           1        0.03          2258        67.87
                    582958           1        0.03          2259        67.90
                    583356           1        0.03          2260        67.93
                    586154           1        0.03          2261        67.96
                    586156           1        0.03          2262        67.99
                    586157           1        0.03          2263        68.02
                    586259           1        0.03          2264        68.05
                    586957           1        0.03          2265        68.08
                    587459           1        0.03          2266        68.11
                    588158           4        0.12          2270        68.23
                    589358           1        0.03          2271        68.26
                    589456           1        0.03          2272        68.29
                    590152           1        0.03          2273        68.32
                    590454           1        0.03          2274        68.35
                    591256           1        0.03          2275        68.38
                    591357           1        0.03          2276        68.41
                    591751           1        0.03          2277        68.44
                    593054           1        0.03          2278        68.47
                    593154           1        0.03          2279        68.50
                    594655           1        0.03          2280        68.53
                    595054           1        0.03          2281        68.56
                    595457           1        0.03          2282        68.59
                    595857           1        0.03          2283        68.62
                    596159           1        0.03          2284        68.65
                    596552           1        0.03          2285        68.68
                    596856           1        0.03          2286        68.71
                    598459           1        0.03          2287        68.74
                    598552           1        0.03          2288        68.77
                    599453           1        0.03          2289        68.80
                    600052           1        0.03          2290        68.83
                    600253           1        0.03          2291        68.86

                                         The SAS System       19:10 Tuesday, March 31, 2020 1382

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    601351           1        0.03          2292        68.89
                    602555           2        0.06          2294        68.95
                    603759           1        0.03          2295        68.98
                    603960           1        0.03          2296        69.01
                    605353           1        0.03          2297        69.04
                    608052           2        0.06          2299        69.10
                    608354           1        0.03          2300        69.13
                    610454           1        0.03          2301        69.16
                    611254           1        0.03          2302        69.19
                    613958           1        0.03          2303        69.22
                    614259           1        0.03          2304        69.25
                    615258           1        0.03          2305        69.28
                    616755           1        0.03          2306        69.31
                    616859           1        0.03          2307        69.34
                    617756           2        0.06          2309        69.40
                    618454           1        0.03          2310        69.43
                    620551           1        0.03          2311        69.46
                    622259           1        0.03          2312        69.49
                    622558           1        0.03          2313        69.52
                    622857           1        0.03          2314        69.55
                    623351           1        0.03          2315        69.58
                    624756           1        0.03          2316        69.61
                    625251           1        0.03          2317        69.64
                    625954           1        0.03          2318        69.67
                    625957           1        0.03          2319        69.70
                    626555           1        0.03          2320        69.73
                    627155           1        0.03          2321        69.76
                    630351           1        0.03          2322        69.79
                    631159           1        0.03          2323        69.82
                    632056           1        0.03          2324        69.85
                    636359           1        0.03          2325        69.88
                    637053           1        0.03          2326        69.91
                    637254           1        0.03          2327        69.94
                    648455           1        0.03          2328        69.97
                    648856           1        0.03          2329        70.00
                    653652           1        0.03          2330        70.03
                    654056           1        0.03          2331        70.06
                    667459           1        0.03          2332        70.09
                    674351           1        0.03          2333        70.12
                    674451           1        0.03          2334        70.15
                    677756           1        0.03          2335        70.18
                    678159           1        0.03          2336        70.21
                    679151           1        0.03          2337        70.24
                    681151           2        0.06          2339        70.30
                    683557           1        0.03          2340        70.33
                    683955           1        0.03          2341        70.36

                                         The SAS System       19:10 Tuesday, March 31, 2020 1383

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    685459           1        0.03          2342        70.39
                    689051           1        0.03          2343        70.42
                    691658           1        0.03          2344        70.45
                    692853           1        0.03          2345        70.48
                    693054           1        0.03          2346        70.51
                    694052           1        0.03          2347        70.54
                    700156           1        0.03          2348        70.57
                    701351           1        0.03          2349        70.60
                    702259           3        0.09          2352        70.69
                    703556           1        0.03          2353        70.72
                    707456           1        0.03          2354        70.75
                    710951           1        0.03          2355        70.78
                    711952           1        0.03          2356        70.81
                    714660           1        0.03          2357        70.84
                    716655           1        0.03          2358        70.87
                    717656           1        0.03          2359        70.90
                    717957           1        0.03          2360        70.93
                    720058           1        0.03          2361        70.96
                    720652           1        0.03          2362        70.99
                    721956           1        0.03          2363        71.02
                    722352           1        0.03          2364        71.06
                    722653           1        0.03          2365        71.09
                    722954           3        0.09          2368        71.18
                    728260           1        0.03          2369        71.21
                    728756           1        0.03          2370        71.24
                    732957           1        0.03          2371        71.27
                    736254           1        0.03          2372        71.30
                    743057           2        0.06          2374        71.36
                    743557           1        0.03          2375        71.39
                    746555           1        0.03          2376        71.42
                    748253           1        0.03          2377        71.45
                    750551           1        0.03          2378        71.48
                    750755           3        0.09          2381        71.57
                    751658           1        0.03          2382        71.60
                    752357           1        0.03          2383        71.63
                    753657           1        0.03          2384        71.66
                    755360           2        0.06          2386        71.72
                    756151           1        0.03          2387        71.75
                    756158           2        0.06          2389        71.81
                    757560           1        0.03          2390        71.84
                    758253           1        0.03          2391        71.87
                    758556           1        0.03          2392        71.90
                    762358           1        0.03          2393        71.93
                    764252           1        0.03          2394        71.96
                    765452           1        0.03          2395        71.99
                    766557           1        0.03          2396        72.02

                                         The SAS System       19:10 Tuesday, March 31, 2020 1384

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    766652           1        0.03          2397        72.05
                    768657           1        0.03          2398        72.08
                    770258           1        0.03          2399        72.11
                    770454           1        0.03          2400        72.14
                    770555           1        0.03          2401        72.17
                    772456           1        0.03          2402        72.20
                    773759           1        0.03          2403        72.23
                    774551           1        0.03          2404        72.26
                    776259           1        0.03          2405        72.29
                    776758           1        0.03          2406        72.32
                    777460           1        0.03          2407        72.35
                    779057           1        0.03          2408        72.38
                    781152           1        0.03          2409        72.41
                    781254           2        0.06          2411        72.47
                    784653           1        0.03          2412        72.50
                    784755           2        0.06          2414        72.56
                    785153           1        0.03          2415        72.59
                    785951           1        0.03          2416        72.62
                    786751           1        0.03          2417        72.65
                    789151           1        0.03          2418        72.68
                    789158           1        0.03          2419        72.71
                    790452           1        0.03          2420        72.74
                    790553           1        0.03          2421        72.77
                    793955           1        0.03          2422        72.80
                    796954           1        0.03          2423        72.83
                    797951           1        0.03          2424        72.86
                    798458           1        0.03          2425        72.89
                    799457           1        0.03          2426        72.92
                    799556           1        0.03          2427        72.95
                    800757           1        0.03          2428        72.98
                    801153           1        0.03          2429        73.01
                    801656           1        0.03          2430        73.04
                    803360           1        0.03          2431        73.07
                    804258           1        0.03          2432        73.10
                    804557           1        0.03          2433        73.13
                    806751           2        0.06          2435        73.19
                    807651           1        0.03          2436        73.22
                    809455           1        0.03          2437        73.25
                    810059           1        0.03          2438        73.28
                    810755           1        0.03          2439        73.31
                    811359           1        0.03          2440        73.34
                    811659           1        0.03          2441        73.37
                    812552           1        0.03          2442        73.40
                    813458           2        0.06          2444        73.46
                    814652           1        0.03          2445        73.49
                    816651           1        0.03          2446        73.52

                                         The SAS System       19:10 Tuesday, March 31, 2020 1385

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    817059           1        0.03          2447        73.55
                    817552           1        0.03          2448        73.58
                    818352           1        0.03          2449        73.61
                    818852           1        0.03          2450        73.64
                    819558           1        0.03          2451        73.67
                    819954           1        0.03          2452        73.70
                    819955           1        0.03          2453        73.73
                    820054           1        0.03          2454        73.76
                    821051           1        0.03          2455        73.79
                    821459           1        0.03          2456        73.82
                    821755           1        0.03          2457        73.85
                    824656           1        0.03          2458        73.88
                    827060           2        0.06          2460        73.94
                    827759           1        0.03          2461        73.97
                    828159           3        0.09          2464        74.06
                    828254           1        0.03          2465        74.09
                    828955           1        0.03          2466        74.12
                    829357           1        0.03          2467        74.15
                    829555           1        0.03          2468        74.18
                    829753           1        0.03          2469        74.21
                    830458           1        0.03          2470        74.24
                    830853           1        0.03          2471        74.27
                    830956           1        0.03          2472        74.30
                    831354           1        0.03          2473        74.33
                    831753           1        0.03          2474        74.36
                    831759           1        0.03          2475        74.39
                    832259           1        0.03          2476        74.42
                    833156           1        0.03          2477        74.45
                    833357           1        0.03          2478        74.48
                    833760           1        0.03          2479        74.51
                    834158           1        0.03          2480        74.54
                    834159           1        0.03          2481        74.57
                    834455           1        0.03          2482        74.60
                    834459           1        0.03          2483        74.63
                    835057           1        0.03          2484        74.66
                    836160           1        0.03          2485        74.69
                    837054           1        0.03          2486        74.72
                    837354           1        0.03          2487        74.75
                    838259           1        0.03          2488        74.78
                    838560           1        0.03          2489        74.81
                    839052           1        0.03          2490        74.84
                    840051           1        0.03          2491        74.87
                    840151           1        0.03          2492        74.90
                    840254           1        0.03          2493        74.93
                    840352           1        0.03          2494        74.96
                    840452           1        0.03          2495        74.99

                                         The SAS System       19:10 Tuesday, March 31, 2020 1386

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    840753           1        0.03          2496        75.02
                    841454           1        0.03          2497        75.05
                    841551           1        0.03          2498        75.08
                    841756           1        0.03          2499        75.11
                    841854           3        0.09          2502        75.20
                    841858           1        0.03          2503        75.23
                    841951           1        0.03          2504        75.26
                    842054           1        0.03          2505        75.29
                    842159           1        0.03          2506        75.32
                    842751           1        0.03          2507        75.35
                    843151           1        0.03          2508        75.38
                    843159           1        0.03          2509        75.41
                    843251           1        0.03          2510        75.44
                    843551           1        0.03          2511        75.47
                    843560           1        0.03          2512        75.50
                    843659           1        0.03          2513        75.53
                    843754           1        0.03          2514        75.56
                    844351           1        0.03          2515        75.59
                    844958           1        0.03          2516        75.62
                    844960           1        0.03          2517        75.65
                    845456           1        0.03          2518        75.68
                    846154           1        0.03          2519        75.71
                    846356           1        0.03          2520        75.74
                    846454           1        0.03          2521        75.77
                    846557           1        0.03          2522        75.80
                    846558           2        0.06          2524        75.86
                    846755           1        0.03          2525        75.89
                    847256           2        0.06          2527        75.95
                    847952           1        0.03          2528        75.98
                    848160           1        0.03          2529        76.01
                    848556           1        0.03          2530        76.04
                    848559           1        0.03          2531        76.07
                    848758           1        0.03          2532        76.10
                    848951           1        0.03          2533        76.13
                    849553           1        0.03          2534        76.16
                    849857           1        0.03          2535        76.19
                    849859           1        0.03          2536        76.22
                    850052           1        0.03          2537        76.25
                    850160           1        0.03          2538        76.28
                    850555           1        0.03          2539        76.31
                    850558           1        0.03          2540        76.35
                    850651           1        0.03          2541        76.38
                    850854           1        0.03          2542        76.41
                    851251           1        0.03          2543        76.44
                    851257           1        0.03          2544        76.47
                    851758           1        0.03          2545        76.50

                                         The SAS System       19:10 Tuesday, March 31, 2020 1387

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    852060           1        0.03          2546        76.53
                    852153           1        0.03          2547        76.56
                    852456           2        0.06          2549        76.62
                    852657           2        0.06          2551        76.68
                    853060           1        0.03          2552        76.71
                    853253           1        0.03          2553        76.74
                    853353           1        0.03          2554        76.77
                    853457           1        0.03          2555        76.80
                    853653           1        0.03          2556        76.83
                    853858           1        0.03          2557        76.86
                    853958           2        0.06          2559        76.92
                    854254           1        0.03          2560        76.95
                    854352           1        0.03          2561        76.98
                    854359           1        0.03          2562        77.01
                    854557           1        0.03          2563        77.04
                    854753           1        0.03          2564        77.07
                    855154           1        0.03          2565        77.10
                    855854           1        0.03          2566        77.13
                    855860           1        0.03          2567        77.16
                    856357           1        0.03          2568        77.19
                    856759           1        0.03          2569        77.22
                    857055           2        0.06          2571        77.28
                    857253           1        0.03          2572        77.31
                    857756           1        0.03          2573        77.34
                    857955           1        0.03          2574        77.37
                    858453           1        0.03          2575        77.40
                    859152           1        0.03          2576        77.43
                    861159           1        0.03          2577        77.46
                    861251           1        0.03          2578        77.49
                    862256           1        0.03          2579        77.52
                    862459           1        0.03          2580        77.55
                    863257           1        0.03          2581        77.58
                    863359           2        0.06          2583        77.64
                    863555           1        0.03          2584        77.67
                    863559           2        0.06          2586        77.73
                    863653           1        0.03          2587        77.76
                    864359           1        0.03          2588        77.79
                    865157           1        0.03          2589        77.82
                    865460           1        0.03          2590        77.85
                    866258           1        0.03          2591        77.88
                    866656           1        0.03          2592        77.91
                    866754           2        0.06          2594        77.97
                    867353           1        0.03          2595        78.00
                    867358           1        0.03          2596        78.03
                    868053           1        0.03          2597        78.06
                    868251           1        0.03          2598        78.09

                                         The SAS System       19:10 Tuesday, March 31, 2020 1388

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    868652           1        0.03          2599        78.12
                    870355           1        0.03          2600        78.15
                    870459           1        0.03          2601        78.18
                    872858           1        0.03          2602        78.21
                    873159           1        0.03          2603        78.24
                    873753           1        0.03          2604        78.27
                    874757           1        0.03          2605        78.30
                    874857           1        0.03          2606        78.33
                    874957           1        0.03          2607        78.36
                    875151           1        0.03          2608        78.39
                    875153           1        0.03          2609        78.42
                    875255           1        0.03          2610        78.45
                    876153           1        0.03          2611        78.48
                    877551           1        0.03          2612        78.51
                    878256           1        0.03          2613        78.54
                    879351           1        0.03          2614        78.57
                    879453           1        0.03          2615        78.60
                    879953           1        0.03          2616        78.63
                    880153           1        0.03          2617        78.66
                    880154           1        0.03          2618        78.69
                    880253           1        0.03          2619        78.72
                    880752           1        0.03          2620        78.75
                    882354           1        0.03          2621        78.78
                    882358           1        0.03          2622        78.81
                    882959           1        0.03          2623        78.84
                    882960           1        0.03          2624        78.87
                    883360           1        0.03          2625        78.90
                    883851           1        0.03          2626        78.93
                    884158           1        0.03          2627        78.96
                    884256           1        0.03          2628        78.99
                    885155           1        0.03          2629        79.02
                    886457           1        0.03          2630        79.05
                    886754           1        0.03          2631        79.08
                    886855           1        0.03          2632        79.11
                    886951           1        0.03          2633        79.14
                    886960           1        0.03          2634        79.17
                    887651           1        0.03          2635        79.20
                    888459           1        0.03          2636        79.23
                    888752           1        0.03          2637        79.26
                    888951           1        0.03          2638        79.29
                    890058           2        0.06          2640        79.35
                    890159           1        0.03          2641        79.38
                    890253           2        0.06          2643        79.44
                    890257           1        0.03          2644        79.47
                    890356           1        0.03          2645        79.50
                    890358           1        0.03          2646        79.53

                                         The SAS System       19:10 Tuesday, March 31, 2020 1389

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    890758           2        0.06          2648        79.59
                    891459           1        0.03          2649        79.62
                    891855           1        0.03          2650        79.65
                    891955           1        0.03          2651        79.68
                    892555           1        0.03          2652        79.71
                    893353           1        0.03          2653        79.74
                    893358           1        0.03          2654        79.77
                    894353           1        0.03          2655        79.80
                    895452           1        0.03          2656        79.83
                    897355           1        0.03          2657        79.86
                    897459           2        0.06          2659        79.92
                    898160           1        0.03          2660        79.95
                    898358           1        0.03          2661        79.98
                    899558           1        0.03          2662        80.01
                    900155           1        0.03          2663        80.04
                    901052           1        0.03          2664        80.07
                    901151           1        0.03          2665        80.10
                    901559           1        0.03          2666        80.13
                    901651           1        0.03          2667        80.16
                    901856           1        0.03          2668        80.19
                    902159           1        0.03          2669        80.22
                    902755           1        0.03          2670        80.25
                    903060           1        0.03          2671        80.28
                    903859           1        0.03          2672        80.31
                    904355           1        0.03          2673        80.34
                    904357           1        0.03          2674        80.37
                    904460           1        0.03          2675        80.40
                    904657           1        0.03          2676        80.43
                    905157           1        0.03          2677        80.46
                    905252           1        0.03          2678        80.49
                    905260           1        0.03          2679        80.52
                    905651           1        0.03          2680        80.55
                    905757           1        0.03          2681        80.58
                    906451           1        0.03          2682        80.61
                    906655           1        0.03          2683        80.64
                    907456           1        0.03          2684        80.67
                    907656           2        0.06          2686        80.73
                    907859           1        0.03          2687        80.76
                    908253           1        0.03          2688        80.79
                    908753           1        0.03          2689        80.82
                    908757           1        0.03          2690        80.85
                    909251           1        0.03          2691        80.88
                    909256           1        0.03          2692        80.91
                    909258           1        0.03          2693        80.94
                    909559           1        0.03          2694        80.97
                    909758           1        0.03          2695        81.00

                                         The SAS System       19:10 Tuesday, March 31, 2020 1390

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    910057          12        0.36          2707        81.36
                    910459           1        0.03          2708        81.39
                    910554           1        0.03          2709        81.42
                    910655           1        0.03          2710        81.45
                    910859           1        0.03          2711        81.48
                    911257           1        0.03          2712        81.51
                    911456           1        0.03          2713        81.54
                    911851           1        0.03          2714        81.57
                    912252           1        0.03          2715        81.61
                    912254           1        0.03          2716        81.64
                    912255           1        0.03          2717        81.67
                    912451           1        0.03          2718        81.70
                    912452           1        0.03          2719        81.73
                    912455           1        0.03          2720        81.76
                    912456           1        0.03          2721        81.79
                    912458           1        0.03          2722        81.82
                    912459           1        0.03          2723        81.85
                    912553           1        0.03          2724        81.88
                    912660           1        0.03          2725        81.91
                    912751           1        0.03          2726        81.94
                    912752           1        0.03          2727        81.97
                    912755           1        0.03          2728        82.00
                    912853           1        0.03          2729        82.03
                    912956           1        0.03          2730        82.06
                    912958           1        0.03          2731        82.09
                    913153           4        0.12          2735        82.21
                    913154           1        0.03          2736        82.24
                    913158           1        0.03          2737        82.27
                    913351           1        0.03          2738        82.30
                    913454           1        0.03          2739        82.33
                    913457           1        0.03          2740        82.36
                    913756           1        0.03          2741        82.39
                    914159           1        0.03          2742        82.42
                    914160           1        0.03          2743        82.45
                    914260           1        0.03          2744        82.48
                    914353           1        0.03          2745        82.51
                    914356           1        0.03          2746        82.54
                    914358           1        0.03          2747        82.57
                    914453           1        0.03          2748        82.60
                    914658           1        0.03          2749        82.63
                    914751           1        0.03          2750        82.66
                    914752           1        0.03          2751        82.69
                    914851           1        0.03          2752        82.72
                    914855           1        0.03          2753        82.75
                    914858           1        0.03          2754        82.78
                    914952           1        0.03          2755        82.81

                                         The SAS System       19:10 Tuesday, March 31, 2020 1391

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    915051           1        0.03          2756        82.84
                    915052           1        0.03          2757        82.87
                    915055           1        0.03          2758        82.90
                    915057           1        0.03          2759        82.93
                    915058           2        0.06          2761        82.99
                    915151           1        0.03          2762        83.02
                    915357           1        0.03          2763        83.05
                    915451           1        0.03          2764        83.08
                    915552           1        0.03          2765        83.11
                    915653           1        0.03          2766        83.14
                    915852           1        0.03          2767        83.17
                    915856           1        0.03          2768        83.20
                    915954           1        0.03          2769        83.23
                    915960           1        0.03          2770        83.26
                    916051           1        0.03          2771        83.29
                    916159           1        0.03          2772        83.32
                    916358           1        0.03          2773        83.35
                    916453           1        0.03          2774        83.38
                    916552           1        0.03          2775        83.41
                    916759           1        0.03          2776        83.44
                    916760           1        0.03          2777        83.47
                    916858           1        0.03          2778        83.50
                    916859           1        0.03          2779        83.53
                    916952           1        0.03          2780        83.56
                    916955           1        0.03          2781        83.59
                    916956           1        0.03          2782        83.62
                    916957           1        0.03          2783        83.65
                    917052           1        0.03          2784        83.68
                    917151           1        0.03          2785        83.71
                    917153           1        0.03          2786        83.74
                    917352           1        0.03          2787        83.77
                    917355           1        0.03          2788        83.80
                    917455           1        0.03          2789        83.83
                    917653           1        0.03          2790        83.86
                    917654           1        0.03          2791        83.89
                    917660           1        0.03          2792        83.92
                    917754           1        0.03          2793        83.95
                    917757           1        0.03          2794        83.98
                    917856           1        0.03          2795        84.01
                    917859           1        0.03          2796        84.04
                    917860           1        0.03          2797        84.07
                    918054           1        0.03          2798        84.10
                    918057           1        0.03          2799        84.13
                    918251           2        0.06          2801        84.19
                    918452           3        0.09          2804        84.28
                    918458           2        0.06          2806        84.34

                                         The SAS System       19:10 Tuesday, March 31, 2020 1392

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    918552           1        0.03          2807        84.37
                    918652           1        0.03          2808        84.40
                    918654           1        0.03          2809        84.43
                    918657           1        0.03          2810        84.46
                    918753           1        0.03          2811        84.49
                    918754           1        0.03          2812        84.52
                    918857           1        0.03          2813        84.55
                    919060           1        0.03          2814        84.58
                    919151           1        0.03          2815        84.61
                    919160           1        0.03          2816        84.64
                    919359           1        0.03          2817        84.67
                    919553           1        0.03          2818        84.70
                    919557           1        0.03          2819        84.73
                    919655           1        0.03          2820        84.76
                    919657           1        0.03          2821        84.79
                    919659           1        0.03          2822        84.82
                    919757           1        0.03          2823        84.85
                    919851           1        0.03          2824        84.88
                    919953           1        0.03          2825        84.91
                    919955           1        0.03          2826        84.94
                    919956           1        0.03          2827        84.97
                    919959           1        0.03          2828        85.00
                    920156           1        0.03          2829        85.03
                    920251           1        0.03          2830        85.06
                    920259           1        0.03          2831        85.09
                    920459           1        0.03          2832        85.12
                    920551           1        0.03          2833        85.15
                    920651           1        0.03          2834        85.18
                    920655           1        0.03          2835        85.21
                    920660           1        0.03          2836        85.24
                    920955           1        0.03          2837        85.27
                    920959           1        0.03          2838        85.30
                    921055           1        0.03          2839        85.33
                    921056           1        0.03          2840        85.36
                    921156           1        0.03          2841        85.39
                    921254           2        0.06          2843        85.45
                    921354           1        0.03          2844        85.48
                    921558           1        0.03          2845        85.51
                    921652           1        0.03          2846        85.54
                    921658           1        0.03          2847        85.57
                    921859           1        0.03          2848        85.60
                    922052           1        0.03          2849        85.63
                    922053           1        0.03          2850        85.66
                    922155           1        0.03          2851        85.69
                    922455           1        0.03          2852        85.72
                    922555           1        0.03          2853        85.75

                                         The SAS System       19:10 Tuesday, March 31, 2020 1393

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    922558           1        0.03          2854        85.78
                    922652           1        0.03          2855        85.81
                    922654           1        0.03          2856        85.84
                    922656           2        0.06          2858        85.90
                    922660           1        0.03          2859        85.93
                    922754           1        0.03          2860        85.96
                    922757           2        0.06          2862        86.02
                    922759           1        0.03          2863        86.05
                    922857           1        0.03          2864        86.08
                    922860           1        0.03          2865        86.11
                    923155           1        0.03          2866        86.14
                    923253           1        0.03          2867        86.17
                    923254           2        0.06          2869        86.23
                    923355           2        0.06          2871        86.29
                    923357           1        0.03          2872        86.32
                    923358           1        0.03          2873        86.35
                    923359           1        0.03          2874        86.38
                    923554           1        0.03          2875        86.41
                    923555           1        0.03          2876        86.44
                    923559           1        0.03          2877        86.47
                    923657           1        0.03          2878        86.50
                    923660           1        0.03          2879        86.53
                    923760           3        0.09          2882        86.62
                    923857           1        0.03          2883        86.65
                    923954           1        0.03          2884        86.68
                    924153           1        0.03          2885        86.71
                    924460           1        0.03          2886        86.74
                    924551           1        0.03          2887        86.77
                    924553           1        0.03          2888        86.80
                    924555           1        0.03          2889        86.83
                    924656           1        0.03          2890        86.87
                    924753           1        0.03          2891        86.90
                    927451           1        0.03          2892        86.93
                    929951           1        0.03          2893        86.96
                    929952           1        0.03          2894        86.99
                    930054           1        0.03          2895        87.02
                    930055           1        0.03          2896        87.05
                    930057           1        0.03          2897        87.08
                    930152           1        0.03          2898        87.11
                    930153           1        0.03          2899        87.14
                    930156           1        0.03          2900        87.17
                    930160           1        0.03          2901        87.20
                    930253           1        0.03          2902        87.23
                    930356           1        0.03          2903        87.26
                    930458           1        0.03          2904        87.29
                    930459           1        0.03          2905        87.32

                                         The SAS System       19:10 Tuesday, March 31, 2020 1394

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    930559           1        0.03          2906        87.35
                    930651           1        0.03          2907        87.38
                    930854           1        0.03          2908        87.41
                    930857           1        0.03          2909        87.44
                    930858           1        0.03          2910        87.47
                    930860           1        0.03          2911        87.50
                    930956           1        0.03          2912        87.53
                    930958           1        0.03          2913        87.56
                    931157           1        0.03          2914        87.59
                    931158           1        0.03          2915        87.62
                    931259           1        0.03          2916        87.65
                    931352           1        0.03          2917        87.68
                    931353           1        0.03          2918        87.71
                    931357           1        0.03          2919        87.74
                    931457           1        0.03          2920        87.77
                    931459           1        0.03          2921        87.80
                    931651           1        0.03          2922        87.83
                    931653           1        0.03          2923        87.86
                    931654           1        0.03          2924        87.89
                    931660           1        0.03          2925        87.92
                    931760           1        0.03          2926        87.95
                    931852           1        0.03          2927        87.98
                    931853           1        0.03          2928        88.01
                    931858           1        0.03          2929        88.04
                    931957           1        0.03          2930        88.07
                    932154           1        0.03          2931        88.10
                    932155           2        0.06          2933        88.16
                    932156           1        0.03          2934        88.19
                    932256           1        0.03          2935        88.22
                    932258           1        0.03          2936        88.25
                    932259           1        0.03          2937        88.28
                    932359           1        0.03          2938        88.31
                    932452           1        0.03          2939        88.34
                    932655           1        0.03          2940        88.37
                    932751           2        0.06          2942        88.43
                    932753           1        0.03          2943        88.46
                    932760           1        0.03          2944        88.49
                    932852           1        0.03          2945        88.52
                    932858           1        0.03          2946        88.55
                    932860           2        0.06          2948        88.61
                    932960           1        0.03          2949        88.64
                    933056           1        0.03          2950        88.67
                    933152           1        0.03          2951        88.70
                    933153           1        0.03          2952        88.73
                    933255           1        0.03          2953        88.76
                    933351           1        0.03          2954        88.79

                                         The SAS System       19:10 Tuesday, March 31, 2020 1395

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    933352           1        0.03          2955        88.82
                    933355           1        0.03          2956        88.85
                    933359           1        0.03          2957        88.88
                    933953           2        0.06          2959        88.94
                    934055           1        0.03          2960        88.97
                    934151           1        0.03          2961        89.00
                    934155           1        0.03          2962        89.03
                    934352           1        0.03          2963        89.06
                    934356           1        0.03          2964        89.09
                    934551           1        0.03          2965        89.12
                    934553           1        0.03          2966        89.15
                    934658           1        0.03          2967        89.18
                    934660           1        0.03          2968        89.21
                    934853           1        0.03          2969        89.24
                    934958           1        0.03          2970        89.27
                    935051           1        0.03          2971        89.30
                    935057           1        0.03          2972        89.33
                    935256           1        0.03          2973        89.36
                    935558           1        0.03          2974        89.39
                    935752           1        0.03          2975        89.42
                    935757           1        0.03          2976        89.45
                    935760           1        0.03          2977        89.48
                    935856           1        0.03          2978        89.51
                    936053           1        0.03          2979        89.54
                    936252           1        0.03          2980        89.57
                    936355           1        0.03          2981        89.60
                    936455           1        0.03          2982        89.63
                    936554           1        0.03          2983        89.66
                    936652           1        0.03          2984        89.69
                    936655           1        0.03          2985        89.72
                    936857           1        0.03          2986        89.75
                    936957           1        0.03          2987        89.78
                    936960           1        0.03          2988        89.81
                    937054           1        0.03          2989        89.84
                    937158           1        0.03          2990        89.87
                    937358           1        0.03          2991        89.90
                    937456           1        0.03          2992        89.93
                    937554           1        0.03          2993        89.96
                    937658           1        0.03          2994        89.99
                    937660           1        0.03          2995        90.02
                    937956           1        0.03          2996        90.05
                    938052           1        0.03          2997        90.08
                    938153           1        0.03          2998        90.11
                    938158           1        0.03          2999        90.14
                    938359           1        0.03          3000        90.17
                    938451           1        0.03          3001        90.20

                                         The SAS System       19:10 Tuesday, March 31, 2020 1396

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    938453           1        0.03          3002        90.23
                    938460           1        0.03          3003        90.26
                    938654           1        0.03          3004        90.29
                    938657           1        0.03          3005        90.32
                    938851           1        0.03          3006        90.35
                    938854           1        0.03          3007        90.38
                    938857           1        0.03          3008        90.41
                    938951           1        0.03          3009        90.44
                    938952           1        0.03          3010        90.47
                    938957           1        0.03          3011        90.50
                    938959           1        0.03          3012        90.53
                    939359           1        0.03          3013        90.56
                    939553           1        0.03          3014        90.59
                    939554           1        0.03          3015        90.62
                    939751           2        0.06          3017        90.68
                    939753           1        0.03          3018        90.71
                    939755           1        0.03          3019        90.74
                    939952           1        0.03          3020        90.77
                    939955           1        0.03          3021        90.80
                    940051           1        0.03          3022        90.83
                    940153           1        0.03          3023        90.86
                    940256           1        0.03          3024        90.89
                    940453           1        0.03          3025        90.92
                    940655           1        0.03          3026        90.95
                    940751           1        0.03          3027        90.98
                    940756           1        0.03          3028        91.01
                    940759           1        0.03          3029        91.04
                    940952           1        0.03          3030        91.07
                    940959           1        0.03          3031        91.10
                    941054           1        0.03          3032        91.13
                    941251           1        0.03          3033        91.16
                    941255           1        0.03          3034        91.19
                    941259           1        0.03          3035        91.22
                    941455           1        0.03          3036        91.25
                    941456           1        0.03          3037        91.28
                    941651           1        0.03          3038        91.31
                    941657           1        0.03          3039        91.34
                    941660           1        0.03          3040        91.37
                    941752           1        0.03          3041        91.40
                    941852           1        0.03          3042        91.43
                    941854           1        0.03          3043        91.46
                    941856           1        0.03          3044        91.49
                    941860           1        0.03          3045        91.52
                    941951           1        0.03          3046        91.55
                    941955           1        0.03          3047        91.58
                    941956           1        0.03          3048        91.61

                                         The SAS System       19:10 Tuesday, March 31, 2020 1397

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    941957           1        0.03          3049        91.64
                    942056           1        0.03          3050        91.67
                    942060           1        0.03          3051        91.70
                    942156           1        0.03          3052        91.73
                    942158           1        0.03          3053        91.76
                    942159           1        0.03          3054        91.79
                    942251           1        0.03          3055        91.82
                    942354           2        0.06          3057        91.88
                    942451           1        0.03          3058        91.91
                    942457           1        0.03          3059        91.94
                    942458           1        0.03          3060        91.97
                    942553           1        0.03          3061        92.00
                    942554           1        0.03          3062        92.03
                    942651           1        0.03          3063        92.06
                    942653           1        0.03          3064        92.09
                    942657           1        0.03          3065        92.13
                    942751           1        0.03          3066        92.16
                    942753           1        0.03          3067        92.19
                    943052           1        0.03          3068        92.22
                    943152           2        0.06          3070        92.28
                    943155           1        0.03          3071        92.31
                    943156           1        0.03          3072        92.34
                    943457           1        0.03          3073        92.37
                    943754           1        0.03          3074        92.40
                    943760           1        0.03          3075        92.43
                    943851           1        0.03          3076        92.46
                    944051           1        0.03          3077        92.49
                    944053           1        0.03          3078        92.52
                    944055           1        0.03          3079        92.55
                    944060           1        0.03          3080        92.58
                    944151           1        0.03          3081        92.61
                    944154           1        0.03          3082        92.64
                    944156           1        0.03          3083        92.67
                    944254           1        0.03          3084        92.70
                    944556           1        0.03          3085        92.73
                    944858           1        0.03          3086        92.76
                    944951           3        0.09          3089        92.85
                    944952           1        0.03          3090        92.88
                    945055           1        0.03          3091        92.91
                    945154           1        0.03          3092        92.94
                    945155           1        0.03          3093        92.97
                    945256           1        0.03          3094        93.00
                    945353           1        0.03          3095        93.03
                    945356           1        0.03          3096        93.06
                    945358           1        0.03          3097        93.09
                    945458           1        0.03          3098        93.12

                                         The SAS System       19:10 Tuesday, March 31, 2020 1398

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    945552           1        0.03          3099        93.15
                    945559           1        0.03          3100        93.18
                    945652           1        0.03          3101        93.21
                    945653           1        0.03          3102        93.24
                    945751           1        0.03          3103        93.27
                    945752           1        0.03          3104        93.30
                    945858           1        0.03          3105        93.33
                    945951           1        0.03          3106        93.36
                    945954           1        0.03          3107        93.39
                    946055           1        0.03          3108        93.42
                    946156           1        0.03          3109        93.45
                    946352           1        0.03          3110        93.48
                    946454           1        0.03          3111        93.51
                    946553           1        0.03          3112        93.54
                    946554           1        0.03          3113        93.57
                    946555           1        0.03          3114        93.60
                    946559           1        0.03          3115        93.63
                    946560           1        0.03          3116        93.66
                    946654           1        0.03          3117        93.69
                    946755           1        0.03          3118        93.72
                    946758           1        0.03          3119        93.75
                    947051           1        0.03          3120        93.78
                    947054           1        0.03          3121        93.81
                    947056           1        0.03          3122        93.84
                    947057           1        0.03          3123        93.87
                    947059           1        0.03          3124        93.90
                    947153           1        0.03          3125        93.93
                    947251           1        0.03          3126        93.96
                    947257           1        0.03          3127        93.99
                    947258           1        0.03          3128        94.02
                    947458           1        0.03          3129        94.05
                    947757           1        0.03          3130        94.08
                    947758           1        0.03          3131        94.11
                    947759           1        0.03          3132        94.14
                    947954           1        0.03          3133        94.17
                    947956           1        0.03          3134        94.20
                    947957           1        0.03          3135        94.23
                    947958           1        0.03          3136        94.26
                    948054           1        0.03          3137        94.29
                    948259           1        0.03          3138        94.32
                    948357           1        0.03          3139        94.35
                    948552           1        0.03          3140        94.38
                    948558           1        0.03          3141        94.41
                    948651           1        0.03          3142        94.44
                    948751           1        0.03          3143        94.47
                    949151           1        0.03          3144        94.50

                                         The SAS System       19:10 Tuesday, March 31, 2020 1399

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    949255           1        0.03          3145        94.53
                    949256           1        0.03          3146        94.56
                    949258           1        0.03          3147        94.59
                    949260           1        0.03          3148        94.62
                    949353           1        0.03          3149        94.65
                    949556           1        0.03          3150        94.68
                    949753           1        0.03          3151        94.71
                    949860           1        0.03          3152        94.74
                    950252           1        0.03          3153        94.77
                    950258           1        0.03          3154        94.80
                    950351           1        0.03          3155        94.83
                    950352           1        0.03          3156        94.86
                    950357           1        0.03          3157        94.89
                    950359           1        0.03          3158        94.92
                    950554           1        0.03          3159        94.95
                    950560           1        0.03          3160        94.98
                    950860           1        0.03          3161        95.01
                    951055           1        0.03          3162        95.04
                    951058           1        0.03          3163        95.07
                    951060           1        0.03          3164        95.10
                    951157           1        0.03          3165        95.13
                    951251           1        0.03          3166        95.16
                    951351           2        0.06          3168        95.22
                    951551           1        0.03          3169        95.25
                    951553           1        0.03          3170        95.28
                    951854           1        0.03          3171        95.31
                    951856           1        0.03          3172        95.34
                    951857           1        0.03          3173        95.37
                    952054           1        0.03          3174        95.40
                    952056           1        0.03          3175        95.43
                    952160           1        0.03          3176        95.46
                    952554           1        0.03          3177        95.49
                    952558           1        0.03          3178        95.52
                    952658           1        0.03          3179        95.55
                    952756           1        0.03          3180        95.58
                    952856           1        0.03          3181        95.61
                    952857           1        0.03          3182        95.64
                    952952           1        0.03          3183        95.67
                    952958           1        0.03          3184        95.70
                    953060           1        0.03          3185        95.73
                    953156           1        0.03          3186        95.76
                    953158           1        0.03          3187        95.79
                    953358           1        0.03          3188        95.82
                    953558           1        0.03          3189        95.85
                    953753           1        0.03          3190        95.88
                    953756           1        0.03          3191        95.91

                                         The SAS System       19:10 Tuesday, March 31, 2020 1400

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    953956           1        0.03          3192        95.94
                    954153           1        0.03          3193        95.97
                    954154           1        0.03          3194        96.00
                    954155           1        0.03          3195        96.03
                    954156           1        0.03          3196        96.06
                    954157           1        0.03          3197        96.09
                    954160           1        0.03          3198        96.12
                    954255           1        0.03          3199        96.15
                    954952           1        0.03          3200        96.18
                    954953           1        0.03          3201        96.21
                    954955           1        0.03          3202        96.24
                    954956           1        0.03          3203        96.27
                    954959           1        0.03          3204        96.30
                    955059           1        0.03          3205        96.33
                    955452           1        0.03          3206        96.36
                    955551           1        0.03          3207        96.39
                    955654           1        0.03          3208        96.42
                    955754           1        0.03          3209        96.45
                    955756           1        0.03          3210        96.48
                    955852           1        0.03          3211        96.51
                    956056           1        0.03          3212        96.54
                    956157           1        0.03          3213        96.57
                    956257           1        0.03          3214        96.60
                    956351           1        0.03          3215        96.63
                    956352           1        0.03          3216        96.66
                    956354           1        0.03          3217        96.69
                    956356           1        0.03          3218        96.72
                    956656           1        0.03          3219        96.75
                    956658           4        0.12          3223        96.87
                    956754           1        0.03          3224        96.90
                    956952           1        0.03          3225        96.93
                    957052           1        0.03          3226        96.96
                    957059           1        0.03          3227        96.99
                    957256           1        0.03          3228        97.02
                    957354           1        0.03          3229        97.05
                    957360           1        0.03          3230        97.08
                    957452           1        0.03          3231        97.11
                    957456           1        0.03          3232        97.14
                    957952           1        0.03          3233        97.17
                    958056           1        0.03          3234        97.20
                    958059           1        0.03          3235        97.23
                    958060           1        0.03          3236        97.26
                    958159           1        0.03          3237        97.29
                    958160           1        0.03          3238        97.32
                    958251           1        0.03          3239        97.35
                    958557           1        0.03          3240        97.39

                                         The SAS System       19:10 Tuesday, March 31, 2020 1401

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    958858           1        0.03          3241        97.42
                    958859           1        0.03          3242        97.45
                    958955           1        0.03          3243        97.48
                    958960           1        0.03          3244        97.51
                    959352           1        0.03          3245        97.54
                    959356           1        0.03          3246        97.57
                    959360           1        0.03          3247        97.60
                    959453           1        0.03          3248        97.63
                    959559           1        0.03          3249        97.66
                    959560           1        0.03          3250        97.69
                    959658           1        0.03          3251        97.72
                    959855           1        0.03          3252        97.75
                    959857           1        0.03          3253        97.78
                    959859           1        0.03          3254        97.81
                    959860           1        0.03          3255        97.84
                    959956           1        0.03          3256        97.87
                    959960           1        0.03          3257        97.90
                    960152           1        0.03          3258        97.93
                    960156           1        0.03          3259        97.96
                    960157           1        0.03          3260        97.99
                    960160           1        0.03          3261        98.02
                    960257           1        0.03          3262        98.05
                    960452           1        0.03          3263        98.08
                    960458           1        0.03          3264        98.11
                    960551           1        0.03          3265        98.14
                    960554           1        0.03          3266        98.17
                    960751           1        0.03          3267        98.20
                    960752           1        0.03          3268        98.23
                    960754           1        0.03          3269        98.26
                    960760           1        0.03          3270        98.29
                    961051           1        0.03          3271        98.32
                    961060           1        0.03          3272        98.35
                    961152           1        0.03          3273        98.38
                    961256           1        0.03          3274        98.41
                    961353           1        0.03          3275        98.44
                    961455           1        0.03          3276        98.47
                    961660           1        0.03          3277        98.50
                    961760           1        0.03          3278        98.53
                    961955           1        0.03          3279        98.56
                    962052           1        0.03          3280        98.59
                    962252           1        0.03          3281        98.62
                    962360           1        0.03          3282        98.65
                    962660           1        0.03          3283        98.68
                    962751           1        0.03          3284        98.71
                    962753           1        0.03          3285        98.74
                    962957           1        0.03          3286        98.77

                                         The SAS System       19:10 Tuesday, March 31, 2020 1402

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                    963053           1        0.03          3287        98.80
                    963153           1        0.03          3288        98.83
                    963252           3        0.09          3291        98.92
                    963255           1        0.03          3292        98.95
                    963355           1        0.03          3293        98.98
                    963655           1        0.03          3294        99.01
                    963756           1        0.03          3295        99.04
                    963757           1        0.03          3296        99.07
                    963759           1        0.03          3297        99.10
                    964056           1        0.03          3298        99.13
                    964059           1        0.03          3299        99.16
                    964252           1        0.03          3300        99.19
                    964256           1        0.03          3301        99.22
                    964353           1        0.03          3302        99.25
                    964451           1        0.03          3303        99.28
                    964551           1        0.03          3304        99.31
                    964553           1        0.03          3305        99.34
                    964554           1        0.03          3306        99.37
                    964651           1        0.03          3307        99.40
                    964853           1        0.03          3308        99.43
                    964856           1        0.03          3309        99.46
                    965057           1        0.03          3310        99.49
                    965157           1        0.03          3311        99.52
                    965354           1        0.03          3312        99.55
                    965358           1        0.03          3313        99.58
                    965359           1        0.03          3314        99.61
                    965558           1        0.03          3315        99.64
                    965559           1        0.03          3316        99.67
                    965560           1        0.03          3317        99.70
                    965654           1        0.03          3318        99.73
                    965657           1        0.03          3319        99.76
                    965660           1        0.03          3320        99.79
                    965757           1        0.03          3321        99.82
                    966060           1        0.03          3322        99.85
                    966153           1        0.03          3323        99.88
                    966252           1        0.03          3324        99.91
                    966259           1        0.03          3325        99.94
                   1038057           1        0.03          3326        99.97
                   1038453           1        0.03          3327       100.00

                                         The SAS System       19:10 Tuesday, March 31, 2020 1403

                                       The FREQ Procedure

                                            encPatWID

                                                       Cumulative    Cumulative
                 encPatWID    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------------
                       460           1        0.03             1         0.03
                       752           1        0.03             2         0.06
                      1259           1        0.03             3         0.09
                      1354           1        0.03             4         0.12
                      1956           1        0.03             5         0.15
                      2751           1        0.03             6         0.18
                      2954           1        0.03             7         0.21
                      3051           1        0.03             8         0.24
                      3052           1        0.03             9         0.27
                      3158           1        0.03            10         0.30
                      3455           1        0.03            11         0.33
                      3554           1        0.03            12         0.36
                      3856           1        0.03            13         0.39
                      4152           1        0.03            14         0.42
                      4258           1        0.03            15         0.45
                      4353           1        0.03            16         0.48
                      4557           1        0.03            17         0.51
                      5758           1        0.03            18         0.54
                      6052           1        0.03            19         0.57
                      7154           1        0.03            20         0.60
                      7557           1        0.03            21         0.63
                      7560           1        0.03            22         0.66
                      7854           2        0.06            24         0.72
                      7955           1        0.03            25         0.75
                      8554           3        0.09            28         0.84
                      8752           1        0.03            29         0.87
                      9551           1        0.03            30         0.90
                      9860           1        0.03            31         0.93
                     10059           2        0.06            33         0.99
                     10157           1        0.03            34         1.02
                     10660           1        0.03            35         1.05
                     10857           1        0.03            36         1.08
                     11555           1        0.03            37         1.11
                     11556           1        0.03            38         1.14
                     11655           1        0.03            39         1.17
                     11854           1        0.03            40         1.20
                     12053           1        0.03            41         1.23
                     12255           1        0.03            42         1.26
                     12352           1        0.03            43         1.29
                     12658           1        0.03            44         1.32
                     12752           1        0.03            45         1.35
                     12854           1        0.03            46         1.38
                     12954           1        0.03            47         1.41
                     13158           1        0.03            48         1.44
                     14153           1        0.03            49         1.47
                     14254           1        0.03            50         1.50

                                         The SAS System       19:10 Tuesday, March 31, 2020 1404

                                       The FREQ Procedure
























