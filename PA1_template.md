---
title: "Reproducible Research: Peer Assessment 1"
author: Oleg Krivosheev
output:
  html_document:
    keep_md: true
---

Peer Assessment 1
=================

This document fulfills the requirements for the peer assessment 1 assignment,
for Coursera course [Reproducible Research](https://class.coursera.org/repdata-035).

## Introduction

We take the problem description verbatim from the original document.

> It is now possible to collect a large amount of data about personal
> movement using activity monitoring devices such as a
> [Fitbit](http://www.fitbit.com), [Nike
> Fuelband](http://www.nike.com/us/en_us/c/nikeplus-fuelband), or
> [Jawbone Up](https://jawbone.com/up). These type of devices are part of
> the "quantified self" movement -- a group of enthusiasts who take
> measurements about themselves regularly to improve their health, to
> find patterns in their behavior, or because they are tech geeks. But
> these data remain under-utilized both because the raw data are hard to
> obtain and there is a lack of statistical methods and software for
> processing and interpreting the data.
>
> This assignment makes use of data from a personal activity monitoring
> device. This device collects data at 5 minute intervals through out the
> day. The data consists of two months of data from an anonymous
> individual collected during the months of October and November, 2012
> and include the number of steps taken in 5 minute intervals each day.

## Data

Data archive is included into the repository. As an alternative, data could
be downloaded from [Activity monitoring data](https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip).

Data description taken verbatim from the assignment.

> The variables included in this dataset are:
>
> * **steps**: Number of steps taking in a 5-minute interval (missing
>     values are coded as `NA`)
>
> * **date**: The date on which the measurement was taken in YYYY-MM-DD
>     format
>
> * **interval**: Identifier for the 5-minute interval in which
>     measurement was taken
>
>
> The dataset is stored in a comma-separated-value (CSV) file and there
> are a total of 17,568 observations in this
> dataset.

## Assignment

There are multiple parts for this assignment. This document will answer all
questions raised as part of an assignment. Document to be processed by **knitr**
and output will be valid HTML file. **R** code in the document will be echoed
so reviewer shall be able to read the code. Each section below will answer one
or more questions raised in the assignment.

## Loading required **R** packages

First, we check if all necessary packages are installed. If not, they
will be installed and loaded.


```r
check_and_install <- function( packname ) {
    # given package name, check if it is installed
    # if not, download and install
    if ( packname %in% rownames(installed.packages()) == FALSE ) {
        install.packages( packname )
    }
}

check_and_install("data.table")
check_and_install("xtable")
check_and_install("ggplot2")

require("data.table")
```

```
## Loading required package: data.table
```

```r
require("xtable")
```

```
## Loading required package: xtable
```

```r
require("ggplot2")
```

```
## Loading required package: ggplot2
## Loading required package: methods
```

## Loading and preprocessing the data

Data as a ZIP archive are located in the same directory as the **R** markdown. Thus,
first we unpack archive and extract CSV file.
Then, we read it and check for consistency. Last, we convert date string to
*Date* and set primary key. Essential features of the [data.table](https://cran.r-project.org/web/packages/data.table/index.html)
package will be used.

### Unpacking and loading data


```r
unzip("activity.zip", "activity.csv")

dt <- fread("activity.csv")
str(dt)
```

```
## Classes 'data.table' and 'data.frame':	17568 obs. of  3 variables:
##  $ steps   : int  NA NA NA NA NA NA NA NA NA NA ...
##  $ date    : chr  "2012-10-01" "2012-10-01" "2012-10-01" "2012-10-01" ...
##  $ interval: int  0 5 10 15 20 25 30 35 40 45 ...
##  - attr(*, ".internal.selfref")=<externalptr>
```

```r
head(dt)
```

```
##    steps       date interval
## 1:    NA 2012-10-01        0
## 2:    NA 2012-10-01        5
## 3:    NA 2012-10-01       10
## 4:    NA 2012-10-01       15
## 5:    NA 2012-10-01       20
## 6:    NA 2012-10-01       25
```

```r
tail(dt)
```

```
##    steps       date interval
## 1:    NA 2012-11-30     2330
## 2:    NA 2012-11-30     2335
## 3:    NA 2012-11-30     2340
## 4:    NA 2012-11-30     2345
## 5:    NA 2012-11-30     2350
## 6:    NA 2012-11-30     2355
```

One can see we have three columns as *int*, *character* and *int*.

### Check for consistency


```r
dims <- dim(dt)

if (dims[1] != 17568) {
    stop("Bad number of rows, should be 17568, bailing out!")
}

if (dims[2] != 3) {
    stop("Bad number of columns, should be 3, bailing out!")
}
```

If we make it so far, data are consistent with our expectations.

### Data preprocessing

First, we prefer to convert second column to proper date.


```r
dt <- dt[ , date := as.Date(date, "%Y-%m-%d")]
```

Second, we make *steps* column a numeric, for easy dealing with
data imputing later.


```r
dt <- dt[ , steps := as.numeric(steps)]

str(dt)
```

```
## Classes 'data.table' and 'data.frame':	17568 obs. of  3 variables:
##  $ steps   : num  NA NA NA NA NA NA NA NA NA NA ...
##  $ date    : Date, format: "2012-10-01" "2012-10-01" ...
##  $ interval: int  0 5 10 15 20 25 30 35 40 45 ...
##  - attr(*, ".internal.selfref")=<externalptr>
```

```r
head(dt)
```

```
##    steps       date interval
## 1:    NA 2012-10-01        0
## 2:    NA 2012-10-01        5
## 3:    NA 2012-10-01       10
## 4:    NA 2012-10-01       15
## 5:    NA 2012-10-01       20
## 6:    NA 2012-10-01       25
```

```r
tail(dt)
```

```
##    steps       date interval
## 1:    NA 2012-11-30     2330
## 2:    NA 2012-11-30     2335
## 3:    NA 2012-11-30     2340
## 4:    NA 2012-11-30     2345
## 5:    NA 2012-11-30     2350
## 6:    NA 2012-11-30     2355
```

Last step is to set primary key for speedy evaluation


```r
setkey(dt, date)
str(dt)
```

```
## Classes 'data.table' and 'data.frame':	17568 obs. of  3 variables:
##  $ steps   : num  NA NA NA NA NA NA NA NA NA NA ...
##  $ date    : Date, format: "2012-10-01" "2012-10-01" ...
##  $ interval: int  0 5 10 15 20 25 30 35 40 45 ...
##  - attr(*, ".internal.selfref")=<externalptr> 
##  - attr(*, "sorted")= chr "date"
```

## What is mean total number of steps taken per day?

Here we will try to answer several question, taken verbatim from the assignment.

> ### Calculate the total number of steps taken per day

We will group data table by date, and then aggregate the number of steps.


```r
dt.steps_by_date <- dt[, sum(steps), by=date]
setnames(dt.steps_by_date, "V1", "steps")

str(dt.steps_by_date)
```

```
## Classes 'data.table' and 'data.frame':	61 obs. of  2 variables:
##  $ date : Date, format: "2012-10-01" "2012-10-02" ...
##  $ steps: num  NA 126 11352 12116 13294 ...
##  - attr(*, "sorted")= chr "date"
##  - attr(*, ".internal.selfref")=<externalptr>
```

```r
head(dt.steps_by_date)
```

```
##          date steps
## 1: 2012-10-01    NA
## 2: 2012-10-02   126
## 3: 2012-10-03 11352
## 4: 2012-10-04 12116
## 5: 2012-10-05 13294
## 6: 2012-10-06 15420
```

```r
tail(dt.steps_by_date)
```

```
##          date steps
## 1: 2012-11-25 11834
## 2: 2012-11-26 11162
## 3: 2012-11-27 13646
## 4: 2012-11-28 10183
## 5: 2012-11-29  7047
## 6: 2012-11-30    NA
```

> ### Make a histogram of the total number of steps taken each day

To make a histogram, we will use **ggplot2** package functionality.
We will make it a gradient plot to look a bit nicer. Also, we would
like to see how bin width affects histrogram appearance.

First, low resolution histogram with bin width equal to 1000.


```r
p <- ggplot(dt.steps_by_date, aes(x = steps)) +
       geom_histogram(alpha=0.3, binwidth=1000,
                     col="red",
                     aes(fill=..count..)) +
       scale_fill_gradient("Count", low = "blue", high = "red") +
       labs(title="Histogram of the total number of steps taken each day") +
       labs(x="Total number of steps", y="Day count")
print(p)
```

![plot of chunk histo_nof_steps_each_day_low](figure/histo_nof_steps_each_day_low-1.png) 

Then, medium resolution histogram with bin width equal to 750.


```r
p <- ggplot(dt.steps_by_date, aes(x = steps)) +
       geom_histogram(alpha=0.3, binwidth=750,
                     col="red",
                     aes(fill=..count..)) +
       scale_fill_gradient("Count", low = "blue", high = "red") +
       labs(title="Histogram of the total number of steps taken each day") +
       labs(x="Total number of steps", y="Day count")
print(p)
```

![plot of chunk histo_nof_steps_each_day_med](figure/histo_nof_steps_each_day_med-1.png) 

Last histogram is a fine one, with bin width equal to 500.


```r
p <- ggplot(dt.steps_by_date, aes(x = steps)) +
       geom_histogram(alpha=0.3, binwidth=500,
                     col="red",
                     aes(fill=..count..)) +
       scale_fill_gradient("Count", low = "blue", high = "red") +
       labs(title="Histogram of the total number of steps taken each day") +
       labs(x="Total number of steps", y="Day count")
print(p)
```

![plot of chunk histo_nof_steps_each_day_high](figure/histo_nof_steps_each_day_high-1.png) 

> ### Calculate and report the mean and median of the total number of steps taken per day

We will calculate the mean and median of the total number of steps taken per day.
Because data still has *NA* values, we will filter them out.
To make a nice table, we will be using [xtable](https://cran.r-project.org/web/packages/xtable/index.html)
package.

First, we make data table *tbl* filtering out *NA* values


```r
tbl <- dt.steps_by_date[, list(N = .N,  mean = mean(steps, na.rm=TRUE), median = median(steps, na.rm=TRUE))]
str(tbl)
```

```
## Classes 'data.table' and 'data.frame':	1 obs. of  3 variables:
##  $ N     : int 61
##  $ mean  : num 10766
##  $ median: num 10765
##  - attr(*, ".internal.selfref")=<externalptr>
```

Then we print *tbl* as a nice embedded HTML table.


```r
print(xtable(tbl), type="html", include.rownames=FALSE)
```

<!-- html table generated in R 3.2.3 by xtable 1.8-0 package -->
<!-- Sun Dec 20 17:35:29 2015 -->
<table border=1>
<tr> <th> N </th> <th> mean </th> <th> median </th>  </tr>
  <tr> <td align="right">  61 </td> <td align="right"> 10766.19 </td> <td align="right"> 10765.00 </td> </tr>
   </table>

## What is the average daily activity pattern?

There are two questions to be answered in this chapter of the assignment.

> ### Make a time series plot of the 5-minute interval (x-axis) and the average number of steps taken, averaged across all days (y-axis)

First, we make new data table, grouped by interval with average number of steps taken.
Of course, *NA* values will be filtered out.


```r
dt.steps_by_interval <- dt[, list(mean = mean(steps, na.rm=TRUE)), by=interval]
str(dt.steps_by_interval)
```

```
## Classes 'data.table' and 'data.frame':	288 obs. of  2 variables:
##  $ interval: int  0 5 10 15 20 25 30 35 40 45 ...
##  $ mean    : num  1.717 0.3396 0.1321 0.1509 0.0755 ...
##  - attr(*, ".internal.selfref")=<externalptr>
```

Now making linear plot, again using **ggplot2** as plotting library.


```r
p <- ggplot(dt.steps_by_interval, aes(x=interval, y=mean)) +
	geom_line(size=1, colour="#CC6666") +
    labs(title="Average number of steps per interval") +
    labs(x="Interval", y="Average number of steps")
print(p)
```

![plot of chunk ave_nof_steps_taken](figure/ave_nof_steps_taken-1.png) 

> ### Which 5-minute interval, on average across all the days in the dataset, contains the maximum number of steps?

To find this value, first we sort our data table by average number of steps in
the descending order, and thus first row will contain asked value in the
*interval* column.


```r
q <- dt.steps_by_interval[order(-mean)]
str(q)
```

```
## Classes 'data.table' and 'data.frame':	288 obs. of  2 variables:
##  $ interval: int  835 840 850 845 830 820 855 815 825 900 ...
##  $ mean    : num  206 196 183 180 177 ...
##  - attr(*, ".internal.selfref")=<externalptr>
```

```r
max_interval <- q[1, interval]
```

The 5-minute interval, on average across all the days in the dataset,
with the largest number of steps is 835.
It is consistent with the displayed graph.

## Imputing missing values

There are a number of days/intervals where there are missing
values (coded as `NA`). The presence of missing days may introduce
bias into some calculations or summaries of the data.

> ### Calculate and report the total number of missing values in the dataset

We use **is.na()** function to get logical vector of missing values.
Then we sum it to produce asked value.


```r
q <- is.na(dt$steps)
mia_steps <- sum(q)
```

Thus, total number of missing values is equal to 2304.

Just in case, checking *NA* in the *date* and *interval* columns


```r
q <- is.na(dt$date)
mia_date <- sum(q)
```

Number of missing dates is equal to 0.


```r
q <- is.na(dt$interval)
mia_interval <- sum(q)
```

Number of missing intervals is equal to 0.

> ### Devise a strategy for filling in all of the missing values in the dataset.

We will use very simple strategy. For each missing value we will replace it with
mean value for the same 5-minute interval computed over all data table.

First, we make helper data table with only two columns, interval versus
average number of steps per interval, with *NA* values removed.


```r
dt.med = dt[, list(mean=mean(steps, na.rm=TRUE)), by=interval]
setkey(dt.med, interval)
str(dt.med)
```

```
## Classes 'data.table' and 'data.frame':	288 obs. of  2 variables:
##  $ interval: int  0 5 10 15 20 25 30 35 40 45 ...
##  $ mean    : num  1.717 0.3396 0.1321 0.1509 0.0755 ...
##  - attr(*, ".internal.selfref")=<externalptr> 
##  - attr(*, "sorted")= chr "interval"
```

> ### Create a new dataset that is equal to the original dataset but with the missing data filled in.

Make a copy of the original data table, which is going to be filled with imputed values.


```r
dt.imp <- copy(dt)
str(dt.imp)
```

```
## Classes 'data.table' and 'data.frame':	17568 obs. of  3 variables:
##  $ steps   : num  NA NA NA NA NA NA NA NA NA NA ...
##  $ date    : Date, format: "2012-10-01" "2012-10-01" ...
##  $ interval: int  0 5 10 15 20 25 30 35 40 45 ...
##  - attr(*, ".internal.selfref")=<externalptr> 
##  - attr(*, "sorted")= chr "date"
```

```r
tables()
```

```
##      NAME                   NROW NCOL MB COLS                KEY     
## [1,] dt                   17,568    3  1 steps,date,interval date    
## [2,] dt.imp               17,568    3  1 steps,date,interval date    
## [3,] dt.med                  288    2  1 interval,mean       interval
## [4,] dt.steps_by_date         61    2  1 date,steps          date    
## [5,] dt.steps_by_interval    288    2  1 interval,mean               
## [6,] tbl                       1    3  1 N,mean,median               
## Total: 6MB
```

We will search in a loop for *NA*, and as soon sa it is found,
we get interval and select mean value of steps from the helper
data table. Value will be rounded to represent ordinal number of steps


```r
for (k in seq_len(nrow(dt.imp))) {
    if (is.na(dt.imp$steps[k])) {
        i <- dt.imp$interval[k]
        q <- dt.med[interval == i]
        dt.imp$steps[k] = round(q$mean)
    }
}

#write.csv(dt.imp, file = "imputed.csv")
```

*Ought to find a better way for such operation*

Now lets check new data table has no *NA* values.


```r
q <- is.na(dt.imp$steps)
sum(q)
```

```
## [1] 0
```

Just in case, check original data table still contains *NA* values.


```r
q <- is.na(dt$steps)
sum(q)
```

```
## [1] 2304
```

> ### Make a histogram of the total number of steps taken each day and Calculate and report the **mean** and **median** total number of steps taken per day. Do these values differ from the estimates from the first part of the assignment?

We will use new data table to compute the total number of steps taken each day.


```r
dt.imp.steps_by_date <- dt.imp[, sum(steps), by=date]
setnames(dt.imp.steps_by_date, "V1", "steps")

str(dt.imp.steps_by_date)
```

```
## Classes 'data.table' and 'data.frame':	61 obs. of  2 variables:
##  $ date : Date, format: "2012-10-01" "2012-10-02" ...
##  $ steps: num  10762 126 11352 12116 13294 ...
##  - attr(*, "sorted")= chr "date"
##  - attr(*, ".internal.selfref")=<externalptr>
```

```r
head(dt.imp.steps_by_date)
```

```
##          date steps
## 1: 2012-10-01 10762
## 2: 2012-10-02   126
## 3: 2012-10-03 11352
## 4: 2012-10-04 12116
## 5: 2012-10-05 13294
## 6: 2012-10-06 15420
```

```r
tail(dt.imp.steps_by_date)
```

```
##          date steps
## 1: 2012-11-25 11834
## 2: 2012-11-26 11162
## 3: 2012-11-27 13646
## 4: 2012-11-28 10183
## 5: 2012-11-29  7047
## 6: 2012-11-30 10762
```

Plotting new histogram, first low resolution


```r
p <- ggplot(dt.imp.steps_by_date, aes(x = steps)) +
       geom_histogram(alpha=0.3, binwidth=1000,
                     col="red",
                     aes(fill=..count..)) +
       scale_fill_gradient("Count", low = "blue", high = "red") +
       labs(title="Imputed histogram of the total number of steps taken each day") +
       labs(x="Total number of steps", y="Day count")
print(p)
```

![plot of chunk histo_nof_steps_each_day_imp_low](figure/histo_nof_steps_each_day_imp_low-1.png) 

then medium


```r
p <- ggplot(dt.imp.steps_by_date, aes(x = steps)) +
       geom_histogram(alpha=0.3, binwidth=750,
                     col="red",
                     aes(fill=..count..)) +
       scale_fill_gradient("Count", low = "blue", high = "red") +
       labs(title="Imputed histogram of the total number of steps taken each day") +
       labs(x="Total number of steps", y="Day count")
print(p)
```

![plot of chunk histo_nof_steps_each_day_imp_med](figure/histo_nof_steps_each_day_imp_med-1.png) 

and, finally, high resolution graph.


```r
p <- ggplot(dt.imp.steps_by_date, aes(x = steps)) +
       geom_histogram(alpha=0.3, binwidth=500,
                     col="red",
                     aes(fill=..count..)) +
       scale_fill_gradient("Count", low = "blue", high = "red") +
       labs(title="Imputed histogram of the total number of steps taken each day") +
       labs(x="Total number of steps", y="Day count")
print(p)
```

![plot of chunk histo_nof_steps_each_day_imp_high](figure/histo_nof_steps_each_day_imp_high-1.png) 

As before, we make table of mean and median.


```r
tbl.imp <- dt.imp.steps_by_date[, list(N = .N,  mean = mean(steps, na.rm=TRUE), median = median(steps, na.rm=TRUE))]
str(tbl.imp)
```

```
## Classes 'data.table' and 'data.frame':	1 obs. of  3 variables:
##  $ N     : int 61
##  $ mean  : num 10766
##  $ median: num 10762
##  - attr(*, ".internal.selfref")=<externalptr>
```

Then we print *tbl.imp* as a nice embedded HTML table.


```r
print(xtable(tbl.imp), type="html", include.rownames=FALSE)
```

<!-- html table generated in R 3.2.3 by xtable 1.8-0 package -->
<!-- Sun Dec 20 17:35:43 2015 -->
<table border=1>
<tr> <th> N </th> <th> mean </th> <th> median </th>  </tr>
  <tr> <td align="right">  61 </td> <td align="right"> 10765.64 </td> <td align="right"> 10762.00 </td> </tr>
   </table>

Now, we combine old and new table to present them together


```r
tbl.sum <- rbind(tbl, tbl.imp)
row.names(tbl.sum) <- c("Original", "Imputed")
```

and print it


```r
print(xtable(tbl.sum), type="html", include.rownames=TRUE)
```

<!-- html table generated in R 3.2.3 by xtable 1.8-0 package -->
<!-- Sun Dec 20 17:35:43 2015 -->
<table border=1>
<tr> <th>  </th> <th> N </th> <th> mean </th> <th> median </th>  </tr>
  <tr> <td align="right"> Original </td> <td align="right">  61 </td> <td align="right"> 10766.19 </td> <td align="right"> 10765.00 </td> </tr>
  <tr> <td align="right"> Imputed </td> <td align="right">  61 </td> <td align="right"> 10765.64 </td> <td align="right"> 10762.00 </td> </tr>
   </table>

Apparently, they are different from non-imputed data, but only slightly.

> ### What is the impact of imputing missing data on the estimates of the total daily number of steps?

The impact of our strategy is very slight change in the mean and median
value of the imputed data table vs original one. The reason for difference being very small
is quite simple - selected strategy by replacing missing values with mean pretty
much guarantees that mean and median would be very close to the original one.

From the other hand, from histograms one can see there is now a lot more days having
particular number of steps taken, so *count* is going up.
This was an expected development, because now there are a lot more days to
contribute to the particular histogram bins.

## Are there differences in activity patterns between weekdays and weekends?

We will use imputed data table for computations and graphs to answer stated question.

> ### Create a new factor variable in the dataset with two levels -- "weekday" and "weekend" indicating whether a given date is a weekday or weekend day.

First, we make character vector with our two factors which match accepted
weekend/weekday numbering scheme (week start with Sunday and ends on Saturday).


```r
thedays <- c("weekend", rep("weekday",5), "weekend")
print(thedays)
```

```
## [1] "weekend" "weekday" "weekday" "weekday" "weekday" "weekday" "weekend"
```

Then we add another column to the imputed data table with factors as
observable. For that, we use *date*, coerse it into POSIXlt type,
take *wday* from ut which would be numeric ranging from 0 to 6.
We add one to have range from 1 to 7, use it as an index to the
*thedays* array and finally treat it all as a factor. Ugh!

But it fits into one line...


```r
dt.imp[, wd := as.factor(thedays[as.POSIXlt(dt.imp$date)$wday + 1])]
str(dt.imp)
```

```
## Classes 'data.table' and 'data.frame':	17568 obs. of  4 variables:
##  $ steps   : num  2 0 0 0 0 2 1 1 0 1 ...
##  $ date    : Date, format: "2012-10-01" "2012-10-01" ...
##  $ interval: int  0 5 10 15 20 25 30 35 40 45 ...
##  $ wd      : Factor w/ 2 levels "weekday","weekend": 1 1 1 1 1 1 1 1 1 1 ...
##  - attr(*, ".internal.selfref")=<externalptr> 
##  - attr(*, "sorted")= chr "date"
```

One can see we have now two-level factor as a forth column. To check
if first date is really a weekday, we could visit [2012-10-01](http://www.dayoftheweek.org/?m=October&d=1&y=2012&go=Go#axzz3utuUEy1w)
on this page, and indeed that day was Monday.

Count number of weekdays and weekends in data table.


```r
q <- dt.imp$wd == "weekday"
weekdays <- sum(q)
q <- dt.imp$wd == "weekend"
weekends <- sum(q)
totaldays <- weekends+weekdays
```

So we have 12960 weekdays and 4608 weekends in our data table
for a total of 17568 (which is equal to the number of observations
in the data table).

> ### Make a panel plot containing a time series plot of the 5-minute interval (x-axis) and the average number of steps taken, averaged across all weekday days or weekend days (y-axis).

Aggregate the average number of steps taken by 5-minute interval.
Use the imputed values in the `steps` variable.


```r
dt.imp.meansteps <- dt.imp[, list(mean = mean(steps, na.rm=TRUE)), by = list(wd, interval)]
```

Plot two time series (one for weekdays and the other for weekends) of the 5-minute intervals and average number of steps taken (imputed values).
We again use **ggplot2*, with facets, to make multy-graph plot.


```r
p <- ggplot(dt.imp.meansteps, aes(x=interval, y=mean, color=wd)) +
	 facet_wrap(~wd, nrow=2) +
	 geom_line(size = 1) +
     labs(title="Time series of the mean number of steps taken per interval and weekday/end") +
     labs(x="Interval", y="Mean number of steps") +
	 theme(legend.position="none")
print(p)
```

![plot of chunk time_series_average_steps_by_interval_wd_imp](figure/time_series_average_steps_by_interval_wd_imp-1.png) 
