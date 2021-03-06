// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

/// @title A contract for selecting the kth smallest element in an array of uints.
/// @author Sasa Milic - <sasa@api3.org>
contract SelectK {
  
  // maximum length of an array that `_medianSmallArray` can handle
  uint256 constant public SMALL_ARRAY_MAX_LENGTH = 16;
    
  // EXTERNAL FUNCTIONS
  
  function computeAndSort
  (
    int256[] memory arr
  )
    external
    pure
    returns (int256 median)
  {
    quickSort(arr, 0, arr.length - 1);
    
    if (arr.length % 2 == 1) {
        median = arr[arr.length / 2];
    } else {
        uint m = arr.length / 2;
        median = (arr[m - 1] + arr[m]) / 2;
    }
  }
  
  function quickSort
  (
    int256[] memory arr,
    uint256 lo,
    uint256 hi
  )
    public
    pure
  {
    if (hi - lo < 1) {
        return;
    }
    uint256 i = partition(arr, lo, hi);
    
    if (i > lo) {quickSort(arr, lo, i - 1);}
    if (i < hi) {quickSort(arr, i + 1, hi);}
  }
  
  ///
  function median
  (
    int256[] memory arr
  )
    external
    pure
    returns (int256)
  {
    if (arr.length % 2 == 1) {
    
      return computeInPlace(arr, arr.length / 2);
    }

  }

/// Returns the kth smallest element in an array of signed ints without
  /// modifying the input array. 
  /// @param arr An array of signed integers.
  /// @param k the rank of the element
  /// @return the kth smallest element in `arr` 
  function compute
  (
    int256[] memory arr,
    uint256 k
  )
    external
    pure
    returns (int256)
  {
    require(k <= arr.length - 1, "k must be a valid index in arr");
    return computeInPlace(copy(arr), k);
  }
  
  ///
  ///
  ///
  function computeInPlace_
  (
    int256[] memory arr,
    uint256 k
  )
    public
    pure
    returns (int256)
  {
    require(k <= arr.length - 1 && arr.length <= SMALL_ARRAY_MAX_LENGTH, "k must be a valid index in arr");
    return selectKsmallArray(arr, k);
  }

  ///
  function medianOfMedians
  (
    int256[] memory arr
  )
    private
    pure
    returns (int256)
  {
    uint noMedians = arr.length / 5;
    
    int[] memory medians = new int[](noMedians + 1);

    uint i0; uint i1; uint i2; uint i3; uint i4; 
    
    for (uint i = 0; i < noMedians; i++) {
      
      i0 = i;
      i1 = i + 1;
      i2 = i + 2;
      i3 = i + 3;
      i4 = i + 4;
      
      // fastest to just sort
      swap(arr, i1, i2); swap(arr, i3, i4); swap(arr, i1, i3);
      swap(arr, i0, i2); swap(arr, i2, i4); swap(arr, i0, i3);
      swap(arr, i0, i1); swap(arr, i2, i3); swap(arr, i1, i2);
    
      medians[i] = arr[i2];
    }
    
    medians[noMedians] = arr[i4 + 1];
    
    return computeInPlace_(medians, noMedians / 2); 
  }

  /// Returns the kth smallest element in an array of signed ints.
  /// @dev The input array `arr` may be modified during the computation.
  /// @param arr An array of unsigned integers.
  /// @param k the rank of the element
  /// @return the kth smallest elements in `arr` 
  function computeInPlace
  (
    int256[] memory arr,
    uint256 k
  )
    public
    pure
    returns (int256)
  {
    require(k <= arr.length - 1, "k must be a valid index in arr");
    if (arr.length <= SMALL_ARRAY_MAX_LENGTH) {
      return selectKsmallArray(arr, k);
    }
    (int256 x1,) = quickSelect(arr, 0, arr.length - 1, k, false);
    return x1;
  }

  // PRIVATE FUNCTIONS

  /// Select the index of the kth element in an array.
  /// @dev This function may modify array.
  /// @param arr an array of uints.
  /// @param lo the left index to begin search.
  /// @param hi the right index to begin search.
  /// @param k the rank of the element
  /// @param selectKplusOne a bool representing whether the function should
  ///                       return the (k+1)st element or not.
  /// @return a tuple (i, j) where i and j are the indices of the kth and
  ///         (k+1)st elements of `arr`, respectively. In the case where
  ///         `selectKplusOne` is false, the tuple returned is (i, 0).
   function quickSelect
  (
    int256[] memory arr,
    uint256 lo,
    uint256 hi,
    uint256 k,
    bool selectKplusOne
  )
    private
    pure
    returns (int256, int256)
  {
      if (lo == hi) {return (arr[k], 0);}

        uint i; uint j; uint idx; int pivot;

        while (lo < hi) {

            pivot = arr[lo];

            i = lo + 1;
            j = hi;

            // partition
            while (true) {
              while (i < arr.length && arr[i] < pivot) {
                i++;
              }
              while (j > 0 && arr[j] > pivot) {
                j--;
              }
              if (i >= j) {
                // swap with pivot
                (arr[lo], arr[j]) = (arr[j], arr[lo]);
                idx = j;
                break;
              }
              (arr[i], arr[j]) = (arr[j], arr[i]);
              i++;
              j--;
            }

            if (k == idx) {return (arr[idx], 0);}

            if (k < idx){
              hi = idx - 1;
            } else {
              lo = idx + 1;
            }
        }
        return (arr[lo], 0);
  }

  
  /// Partitions the array in-place using a modified Hoare's partitioning
  /// scheme. Only elements between indices `lo` and `high` (inclusive) will be
  /// partitioned.
  /// @dev Hoare's algorithm is modified in order to return the index of the
  ///      pivot element.
  /// @return the index of the pivot
  function partition
  (
    int256[] memory arr,
    uint256 lo,
    uint256 hi
  )
    public
    pure
    returns (uint256)
  {
    if (lo == hi) {return lo;}

    int pivot = arr[lo];
    uint pivot_idx = lo;

    lo++;

    while (true) {
      while (lo < arr.length && arr[lo] <= pivot) {
        lo++;
      }
      while (hi > 0 && arr[hi] >= pivot) {
        hi--;
      }
      if (lo >= hi) {
        // swap with pivot
        (arr[pivot_idx], arr[hi]) = (arr[hi], arr[pivot_idx]);
        return hi;
      }
      (arr[lo], arr[hi]) = (arr[hi], arr[lo]);
      lo++;
      hi--;
    }
  }
  
  ///
  ///
  ///
  function partitionWithPivot
  (
    int256[] memory arr,
    uint256 lo,
    uint256 hi,
    int256 pivot
  )
    public
    pure
    returns (uint256)
  {
    if (lo == hi) {return lo;}
    
    uint idx;
    for (uint i = 0; i < arr.length; i++) {
      if (arr[i] == pivot) {
        idx = i;
        break;
      }
    }
    (arr[lo], arr[idx]) = (arr[idx], arr[lo]);

    uint i = lo;
    uint j = hi + 1;
 
    while (true) {
      do {
        i++;
      } while (i < arr.length && arr[i] < pivot);
      do {
        j--;
      } while (arr[j] > pivot);
      if (i >= j) {
        // swap with pivot
        (arr[lo], arr[j]) = (arr[j], arr[lo]);
        return j;
      } 
      (arr[i], arr[j]) = (arr[j], arr[i]);
    }
  }

  /// Return the kth element of a small array (at most length 16).
  /// @dev The input array `arr` may be modified during the computation.
  /// @param arr an array of signed integers (at most length 16)
  /// @return the kth smallest element in `arr`
  function selectKsmallArray
  (
    int256[] memory arr,
    uint256 k
  )
      private
      pure
      returns (int256)
  {
    assert(arr.length <= SMALL_ARRAY_MAX_LENGTH);

    if (arr.length == 2) {
      swap(arr, 0, 1);
    }
    else if (arr.length == 3) {
      swap(arr, 0, 1); swap(arr, 1, 2); swap(arr, 0, 1);
    }
    else if (arr.length == 4) {
      swap(arr, 0, 1); swap(arr, 2, 3); swap(arr, 1, 3);
      swap(arr, 0, 2); swap(arr, 1, 2);
    }
    else if (arr.length == 5) {
      swap(arr, 1, 2); swap(arr, 3, 4); swap(arr, 1, 3);
      swap(arr, 0, 2); swap(arr, 2, 4); swap(arr, 0, 3);
      swap(arr, 0, 1); swap(arr, 2, 3); swap(arr, 1, 2);
    }
    else if (arr.length == 6) {
      swap(arr, 0, 1); swap(arr, 2, 3); swap(arr, 4, 5);
      swap(arr, 1, 3); swap(arr, 3, 5); swap(arr, 1, 3);
      swap(arr, 2, 4); swap(arr, 0, 2); swap(arr, 2, 4);
      swap(arr, 3, 4); swap(arr, 1, 2); swap(arr, 2, 3);
    }
    else if (arr.length == 7) {
      swap(arr, 1, 2); swap(arr, 3, 4); swap(arr, 5, 6);
      swap(arr, 0, 2); swap(arr, 4, 6); swap(arr, 3, 5);
      swap(arr, 2, 6); swap(arr, 1, 5); swap(arr, 0, 4);
      swap(arr, 2, 5); swap(arr, 0, 3); swap(arr, 2, 4);
      swap(arr, 1, 3); swap(arr, 0, 1); swap(arr, 2, 3);
      swap(arr, 4, 5);
    }
    else if (arr.length == 8) {
      swap(arr, 0, 7); swap(arr, 1, 6); swap(arr, 2, 5);
      swap(arr, 3, 4); swap(arr, 0, 3); swap(arr, 4, 7);
      swap(arr, 1, 2); swap(arr, 5, 6); swap(arr, 0, 1);
      swap(arr, 2, 3); swap(arr, 4, 5); swap(arr, 6, 7);
      swap(arr, 3, 5); swap(arr, 2, 4); swap(arr, 1, 2);
      swap(arr, 3, 4); swap(arr, 5, 6); swap(arr, 2, 3);
      swap(arr, 4, 5);
    }
    else if (arr.length == 9) {
      swap(arr, 1, 8); swap(arr, 2, 7); swap(arr, 3, 6);
      swap(arr, 4, 5); swap(arr, 1, 4); swap(arr, 5, 8);
      swap(arr, 0, 2); swap(arr, 6, 7); swap(arr, 2, 6);
      swap(arr, 7, 8); swap(arr, 0, 3); swap(arr, 4, 5);
      swap(arr, 0, 1); swap(arr, 3, 5); swap(arr, 6, 7);
      swap(arr, 2, 4); swap(arr, 1, 3); swap(arr, 5, 7);
      swap(arr, 4, 6); swap(arr, 1, 2); swap(arr, 3, 4);
      swap(arr, 5, 6); swap(arr, 7, 8); swap(arr, 2, 3);
      swap(arr, 4, 5);
    }
    else if (arr.length == 10) {
      swap(arr, 0, 1);  swap(arr, 2, 3); swap(arr, 4, 5);
      swap(arr, 6, 7);  swap(arr, 8, 9); swap(arr, 4, 9);
      swap(arr, 0, 5);  swap(arr, 1, 8); swap(arr, 3, 7);
      swap(arr, 2, 6);  swap(arr, 0, 2); swap(arr, 3, 6);
      swap(arr, 7, 9);  swap(arr, 1, 4); swap(arr, 5, 8);
      swap(arr, 0, 1);  swap(arr, 2, 7); swap(arr, 8, 9);
      swap(arr, 4, 6);  swap(arr, 3, 5); swap(arr, 2, 4);
      swap(arr, 6, 8);  swap(arr, 1, 3); swap(arr, 5, 7);
      swap(arr, 1, 2);  swap(arr, 3, 4); swap(arr, 5, 6);
      swap(arr, 7, 8);  swap(arr, 2, 3); swap(arr, 4, 5);
      swap(arr, 6, 7);
    }
    else if (arr.length == 11) {
      swap(arr, 0, 9);  swap(arr, 1, 8);  swap(arr, 2, 7);
      swap(arr, 3, 6);  swap(arr, 4, 5);  swap(arr, 0, 3);
      swap(arr, 1, 2);  swap(arr, 4, 10); swap(arr, 6, 9);
      swap(arr, 7, 8);  swap(arr, 0, 1);  swap(arr, 2, 3);
      swap(arr, 5, 8);  swap(arr, 9, 10); swap(arr, 6, 7);
      swap(arr, 1, 2);  swap(arr, 4, 6);  swap(arr, 8, 10);
      swap(arr, 5, 9);  swap(arr, 0, 4);  swap(arr, 7, 8);
      swap(arr, 1, 5);  swap(arr, 2, 9);  swap(arr, 3, 6);
      swap(arr, 1, 4);  swap(arr, 5, 7);  swap(arr, 2, 3);
      swap(arr, 6, 9);  swap(arr, 2, 4);  swap(arr, 6, 7);
      swap(arr, 8, 9);  swap(arr, 3, 5);  swap(arr, 3, 4);
      swap(arr, 5, 6);  swap(arr, 7, 8);
    }
    else if (arr.length == 12) {
      swap(arr, 0, 6);   swap(arr, 1, 7);  swap(arr, 2, 8);
      swap(arr, 3, 9);   swap(arr, 4, 10); swap(arr, 5, 11);
      swap(arr, 0, 3);   swap(arr, 1, 4);  swap(arr, 2, 5);
      swap(arr, 6, 9);   swap(arr, 7, 10); swap(arr, 8, 11);
      swap(arr, 0, 1);   swap(arr, 3, 4);  swap(arr, 5, 8);
      swap(arr, 10, 11); swap(arr, 6, 7);  swap(arr, 1, 2);
      swap(arr, 3, 6);   swap(arr, 7, 8);  swap(arr, 9, 10);
      swap(arr, 4, 5);   swap(arr, 0, 1);  swap(arr, 2, 9);
      swap(arr, 10, 11); swap(arr, 3, 4);  swap(arr, 5, 8);
      swap(arr, 6, 7);   swap(arr, 1, 3);  swap(arr, 4, 7);
      swap(arr, 8, 10);  swap(arr, 2, 6);  swap(arr, 5, 9);
      swap(arr, 2, 3);   swap(arr, 4, 6);  swap(arr, 8, 9);
      swap(arr, 5, 7);   swap(arr, 3, 4);  swap(arr, 5, 6);
      swap(arr, 7, 8);
    }
    else if (arr.length == 13) {
      swap(arr, 1, 12); swap(arr, 2, 11);  swap(arr, 3, 10);
      swap(arr, 4, 9);  swap(arr, 5, 8);   swap(arr, 6, 7);
      swap(arr, 0, 5);  swap(arr, 1, 4);   swap(arr, 2, 3);
      swap(arr, 9, 12); swap(arr, 10, 11); swap(arr, 3, 6);
      swap(arr, 7, 10); swap(arr, 0, 1);   swap(arr, 4, 5);
      swap(arr, 8, 9);  swap(arr, 1, 7);   swap(arr, 9, 10);
      swap(arr, 2, 8);  swap(arr, 3, 4);   swap(arr, 5, 11);
      swap(arr, 6, 12); swap(arr, 0, 3);   swap(arr, 4, 9);
      swap(arr, 1, 2);  swap(arr, 5, 8);   swap(arr, 11, 12);
      swap(arr, 6, 7);  swap(arr, 0, 1);   swap(arr, 2, 3);
      swap(arr, 4, 7);  swap(arr, 10, 11); swap(arr, 5, 9);
      swap(arr, 6, 8);  swap(arr, 1, 2);   swap(arr, 3, 5);
      swap(arr, 8, 10); swap(arr, 11, 12); swap(arr, 4, 6);
      swap(arr, 7, 9);  swap(arr, 3, 4);   swap(arr, 5, 6);
      swap(arr, 7, 8);  swap(arr, 9, 10);  swap(arr, 2, 3);
      swap(arr, 4, 5);  swap(arr, 6, 7);   swap(arr, 8, 9);
      swap(arr, 10, 11);
    }
    else if (arr.length == 14) {
      swap(arr, 0, 13);  swap(arr, 1, 12); swap(arr, 2, 11);
      swap(arr, 3, 10);  swap(arr, 4, 9);  swap(arr, 5, 8);
      swap(arr, 6, 7);   swap(arr, 0, 5);  swap(arr, 1, 4);
      swap(arr, 2, 3);   swap(arr, 8, 13); swap(arr, 9, 12);
      swap(arr, 10, 11); swap(arr, 3, 6);  swap(arr, 7, 10);
      swap(arr, 0, 1);   swap(arr, 4, 5);  swap(arr, 8, 9);
      swap(arr, 12, 13); swap(arr, 1, 7);  swap(arr, 9, 10);
      swap(arr, 2, 8);   swap(arr, 3, 4);  swap(arr, 5, 11);
      swap(arr, 6, 12);  swap(arr, 0, 3);  swap(arr, 4, 9);
      swap(arr, 10, 13); swap(arr, 1, 2);  swap(arr, 5, 8);
      swap(arr, 11, 12); swap(arr, 6, 7);  swap(arr, 0, 1);
      swap(arr, 2, 3);   swap(arr, 4, 7);  swap(arr, 10, 11);
      swap(arr, 12, 13); swap(arr, 5, 9);  swap(arr, 6, 8);
      swap(arr, 1, 2);   swap(arr, 3, 5);  swap(arr, 8, 10);
      swap(arr, 11, 12); swap(arr, 4, 6);  swap(arr, 7, 9);
      swap(arr, 3, 4);   swap(arr, 5, 6);  swap(arr, 7, 8);
      swap(arr, 9, 10);  swap(arr, 2, 3);  swap(arr, 4, 5);
      swap(arr, 6, 7);   swap(arr, 8, 9);  swap(arr, 10, 11);
    }
    else if (arr.length == 15) {
      swap(arr, 1, 14);  swap(arr, 2, 13);  swap(arr, 3, 12);
      swap(arr, 4, 11);  swap(arr, 5, 10);  swap(arr, 6, 9);
      swap(arr, 7, 8);   swap(arr, 0, 7);   swap(arr, 1, 6);
      swap(arr, 2, 5);   swap(arr, 3, 4);   swap(arr, 9, 14);
      swap(arr, 10, 13); swap(arr, 11, 12); swap(arr, 0, 3);
      swap(arr, 4, 7);   swap(arr, 8, 11);  swap(arr, 1, 2);
      swap(arr, 5, 6);   swap(arr, 9, 10);  swap(arr, 13, 14);
      swap(arr, 0, 1);   swap(arr, 2, 8);   swap(arr, 10, 11);
      swap(arr, 3, 9);   swap(arr, 4, 5);   swap(arr, 6, 12);
      swap(arr, 7, 13);  swap(arr, 1, 4);   swap(arr, 5, 10);
      swap(arr, 11, 14); swap(arr, 2, 3);   swap(arr, 6, 9);
      swap(arr, 12, 13); swap(arr, 7, 8);   swap(arr, 1, 2);
      swap(arr, 3, 4);   swap(arr, 5, 8);   swap(arr, 11, 12);
      swap(arr, 13, 14); swap(arr, 6, 10);  swap(arr, 7, 9);
      swap(arr, 2, 3);   swap(arr, 4, 6);   swap(arr, 9, 11);
      swap(arr, 12, 13); swap(arr, 5, 7);   swap(arr, 8, 10);
      swap(arr, 4, 5);   swap(arr, 6, 7);   swap(arr, 8, 9);
      swap(arr, 10, 11); swap(arr, 3, 4);   swap(arr, 5, 6);
      swap(arr, 7, 8);   swap(arr, 9, 10);  swap(arr, 11, 12);
    }
    else if (arr.length == 16) {
      swap(arr, 0, 15);  swap(arr, 1, 14);  swap(arr, 2, 13);
      swap(arr, 3, 12);  swap(arr, 4, 11);  swap(arr, 5, 10);
      swap(arr, 6, 9);   swap(arr, 7, 8);   swap(arr, 0, 7);
      swap(arr, 1, 6);   swap(arr, 2, 5);   swap(arr, 3, 4);
      swap(arr, 8, 15);  swap(arr, 9, 14);  swap(arr, 10, 13);
      swap(arr, 11, 12); swap(arr, 0, 3);   swap(arr, 4, 7);
      swap(arr, 8, 11);  swap(arr, 12, 15); swap(arr, 1, 2);
      swap(arr, 5, 6);   swap(arr, 9, 10);  swap(arr, 13, 14);
      swap(arr, 0, 1);   swap(arr, 2, 8);   swap(arr, 10, 11);
      swap(arr, 14, 15); swap(arr, 3, 9);   swap(arr, 4, 5);
      swap(arr, 6, 12);  swap(arr, 7, 13);  swap(arr, 1, 4);
      swap(arr, 5, 10);  swap(arr, 11, 14); swap(arr, 2, 3);
      swap(arr, 6, 9);   swap(arr, 12, 13); swap(arr, 7, 8);
      swap(arr, 1, 2);   swap(arr, 3, 4);   swap(arr, 5, 8);
      swap(arr, 11, 12); swap(arr, 13, 14); swap(arr, 6, 10);
      swap(arr, 7, 9);   swap(arr, 2, 3);   swap(arr, 4, 6);
      swap(arr, 9, 11);  swap(arr, 12, 13); swap(arr, 5, 7);
      swap(arr, 8, 10);  swap(arr, 4, 5);   swap(arr, 6, 7);
      swap(arr, 8, 9);   swap(arr, 10, 11); swap(arr, 3, 4);
      swap(arr, 5, 6);   swap(arr, 7, 8);   swap(arr, 9, 10);
      swap(arr, 11, 12);
    }
    return arr[k];
  }

  /// Swap two elements of an array iff the first element
  /// is greater than the second.
  /// @param arr an array of unsigned integers
  /// @param i the first index
  /// @param j the second index
  function swap
  (
    int256[] memory arr,
    uint256 i,
    uint256 j
  )
    private
    pure
  {
    assert(i < j);
    if (arr[i] > arr[j]) {(arr[i], arr[j]) = (arr[j], arr[i]);}
  }

  /// Make an in-memory copy of an array
  /// @param arr The array to be copied.
  function copy
  (
    int256[] memory arr
  )
    private
    pure
    returns(int256[] memory)
  {
    int256[] memory arr2 = new int256[](arr.length);
    for (uint i = 0; i < arr.length; i++) {
      arr2[i] = arr[i];
    }
    return arr2;
  }
}

