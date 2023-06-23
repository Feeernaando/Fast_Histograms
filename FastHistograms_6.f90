PROGRAM FAST_HISTOGRAMS_6
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
! The following programme creates a histogram from a datafile and store it in a comma separated file with the following format
!	Number of bin , Height of the bin
! The code was created with performace in mind and is capable of creating histograms from files of up to 1x10^(10) rows in less than 10 minutes.
!
! To graph the histogram file gnuplot can be used. the file called 'plot_histogarm.plt' is a brief snippet of nuplot that can be used to plot the histogram file.
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
USE, INTRINSIC :: IEEE_ARITHMETIC !Library to be able to find NAN and Infty values in files.

IMPLICIT NONE

INTEGER, PARAMETER :: DP = SELECTED_REAL_KIND(32)
INTEGER, PARAMETER :: IDP = SELECTED_INT_KIND(8)

!####
!Name of the file with the data that is to be sorted in a histogram.
CHARACTER(LEN=120) :: DATAFILE_OF_INTEREST = &
!'direction/file'
'Ex_Data.dat'
!Name of the file where the bins and height are stores, i.e. the histogram
CHARACTER(LEN=120) :: HISTOGRAM_FILE = &
'HISTOGRAM_Ex_Data.dat'

!Number of datapoints known in the file.
INTEGER(KIND = IDP), PARAMETER :: N = 10000

!Parameters to set the histograms charateristics 
REAL(KIND = DP), PARAMETER :: BIN_SIZE = 0.001  !With this variable you can set the size of the bins. !To be printed fully is necesary to configure the amount of characters to be printed at lines 113 and 120
REAL(KIND = DP), PARAMETER :: CENTRAL_VALUE = 0.0 !With this variable you set the central value of the histogram, by default it can be left set at 0.0.
REAL(KIND = DP), PARAMETER :: RIGHT_BOUND =  2 !With this variable you set the maximum value of the data to be considered while creating the histogram.
REAL(KIND = DP), PARAMETER :: LEFT_BOUND = -2 !With this variable you set the minimum value of the data to be considered while creating the histogram, if negative the minus has to be included in the stated value.

!Variables to create the array that will contain the bins to be filled in order to create the histogram. 
!The values that were set above are tranlated into bins considering the bins size.
INTEGER(KIND = IDP), PARAMETER :: CENTRAL_BIN = CENTRAL_VALUE/BIN_SIZE !
INTEGER(KIND = IDP), PARAMETER :: RIGHT_BOUND_BIN = INT(CENTRAL_VALUE/BIN_SIZE) + INT(RIGHT_BOUND/BIN_SIZE) !
INTEGER(KIND = IDP), PARAMETER :: LEFT_BOUND_BIN = INT(CENTRAL_VALUE/BIN_SIZE) + INT(LEFT_BOUND/BIN_SIZE)!
REAL(KIND = DP), DIMENSION(LEFT_BOUND_BIN:RIGHT_BOUND_BIN) :: BIN_A = 0.0 ! The array that contains the bins of the histogram.

!Variables to be used to fill the histogram array BIN_A.
INTEGER(KIND = IDP) :: COUNT_BIN_A = 0.0, i, Y_Prima = 0.0, Counting_Data = 0.0, Counting_C_Data = 0.0
REAL(KIND = DP) :: Dummy = 0.0
REAL(KIND = DP) :: Y_j = 0.0
CHARACTER(LEN=50) :: Dummy_Char 

!Variables to measure the execution time.
REAL(KIND = DP) :: START = 0.0, FINISH = 0.0 
CHARACTER(LEN=30) :: date_time

!To begin to measure execution time.
CALL CPU_TIME(START)

!Brief description of the porgramme to be printed in terminal
WRITE(*,*) 'This program analyse a datafile to create a histogram using such data.'
WRITE(*,*) 'The file to be analysed is the fillowing: ',DATAFILE_OF_INTEREST
WRITE(*,*) 'The file where the histogram is stored is: ',HISTOGRAM_FILE

!The file to be read is opened.
OPEN(UNIT=13,FILE=DATAFILE_OF_INTEREST,STATUS='UNKNOWN',ACTION='READ')

!Beginning time is printed in terminal in order to measure the execution time.
CALL fdate(date_time)
WRITE(*,*) 'Beginning time:',date_time

WRITE(*,*) 'The histograms is being generated'
	
DO i = 1, N-1
	
	COUNT_BIN_A = 0.0
	
	!To readmonocolumn data
	READ(13,*) Y_j

	!This if is used in case the file contains rows with "weird" data.
	IF ( (ieee_is_finite(Y_j) .neqv. .TRUE.) .OR. (ieee_is_NAN(Y_j) .eqv. .TRUE.) ) THEN
		CONTINUE
	ELSE
		
		Y_Prima = INT( (Y_j/BIN_SIZE) ) !The data is divided by the bin size to fill the proper bin.

		!This IF evaluates if the value read is contained in the interval declared at the beginning.
		IF ( (Y_Prima < LEFT_BOUND_BIN) .OR. (Y_Prima > RIGHT_BOUND_BIN) ) THEN
			CONTINUE
		ELSE 
			!WRITE statement to check the code
			!WRITE(*,*)Y_Prima

			BIN_A(Y_Prima) = BIN_A(Y_Prima) + 1.0
			Counting_C_Data = Counting_C_Data + 1.0

			!WRITE statements to check the code
			!WRITE(*,*) 'Hello, we are inside the IF that fills the array BIN_A'
			!WRITE(*,*) BIN_A(Y_Prima)

			Y_j = 0.0 !Variable Y_j is set to cero to avoid saturating the variable.
		
		END IF
	
	END IF

	Dummy = 0.0
	Counting_Data = Counting_Data + 1.0

END DO

 CLOSE(UNIT = 13)

!File were the histogram is saved is opened
OPEN(UNIT=11,FILE=HISTOGRAM_FILE,STATUS='UNKNOWN',ACTION='WRITE')

WRITE(*,*) 'The histogram has been generated.'
WRITE(*,*) 'THe histogram file is being filled.' 


DO i = LEFT_BOUND_BIN, CENTRAL_BIN
 
	WRITE(11,'(F0.6,A1,F0.0)') i*BIN_SIZE,',',BIN_A(i)
	!WRITE(*,*) i
END DO


DO i= CENTRAL_BIN+1 , RIGHT_BOUND_BIN
 
	WRITE(11,'(F0.6,A1,F0.0)') i*BIN_SIZE,',',BIN_A(i)
	!WRITE(*,*) i
	
END DO

 CLOSE(UNIT=11)

WRITE(*,*) 'The histogram considers', Counting_C_Data,'data points out of',Counting_Data,'of the total amount provided by the file'
WRITE(*,*) 'If not all the datapoints are considered try making the RIGHT_BOUND and LEFT_BOUND bigger.'   

CALL CPU_TIME(FINISH)
WRITE(*,*)'The execution time in seconds was of ', FINISH-START, ' seconds.'

!Finnishing time is printed in terminal in order to measure the execution time.
CALL FDATE(date_time)
WRITE(*,*) 'Finnishing time:',date_time


END PROGRAM FAST_HISTOGRAMS_6
