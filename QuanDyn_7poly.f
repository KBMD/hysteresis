         Subroutine Model(CurSet,
     C                   NoOfParams,
     C                   NoOfDerived,
     C                   TotalDataValues,
     C                   MaxNoOfDataValues,
     C                   NoOfDataCols,
     C                   NoOfAbscissaCols,
     C                   NoOfModelVectors,
     C                   Params,
     C                   Derived,
     C                   Abscissa,
     C                   Gij)

        Implicit  None
        Integer,       Intent(In)::   CurSet
        Integer,       Intent(In)::   NoOfParams
        Integer,       Intent(In)::   NoOfDerived
        Integer,       Intent(In)::   TotalDataValues
        Integer,       Intent(In)::   MaxNoOfDataValues
        Integer,       Intent(In)::   NoOfDataCols
        Integer,       Intent(In)::   NoOfAbscissaCols
        Integer,       Intent(In)::   NoOfModelVectors
        Real (Kind=8), Intent(In)::   Params(NoOfParams)
        Real (Kind=8), Intent(InOut)::Derived(NoOfDerived)
        Real (Kind=8), Intent(In)::   Abscissa(NoOfAbscissaCols,MaxNoOfDataValues)
        Real (Kind=8), Intent(InOut)::Gij(NoOfDataCols,MaxNoOfDataValues,NoOfModelVectors)
        Integer        NoOfPoly
        Parameter     (NoOfPoly=7)
        Integer        CurEntry
        Integer        PolyNum
		
        Derived(1)=0
        Derived(2)=0
        Derived(3)=0
        Derived(4)=0
		
        Do CurEntry = 1, TotalDataValues
           Do PolyNum = 1, NoOfPoly
              Gij(1,CurEntry,PolyNum) = Abscissa(1,CurEntry)**(PolyNum-1)
           EndDo
        EndDo

        Return
        End
