// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

/// @title A contract for computing the median of an array of uints.
/// @author Sasa Milic - <sasa@api3.org>
contract Median {

    /// Computes a median on an array of unsigned integers of any length.
    /// @param arr An array of unsigned integers.
    /// @return median of `array` 
    function compute
    (
      int256[] memory arr
    )
      external
      pure
      returns (int256 median)
    {
      mergeSort(arr, 0, arr.length - 1);
      
      if (arr.length % 2 == 1) {
        median = arr[arr.length / 2];
      } else {
        uint m = arr.length / 2;
        median = (arr[m - 1] + arr[m]) / 2;
      }
    }
    
    function mergeSort
    (
      int256[] memory arr,
      uint256 l,
      uint256 r
    )
      public
      pure
      returns (int256[] memory)
    {
      if (l >= r) {return arr;}

      uint m;
      m = l + (r - l) / 2;

      mergeSort(arr, l, m);
      mergeSort(arr, m + 1, r);

      uint start2 = m + 1;

      if (arr[m] <= arr[start2]) {
        return arr;
      }

      int256 value;
      uint256 index;

      while (l <= m && start2 <= r) {

        if (arr[l] <= arr[start2]) {

            l += 1;

        } else {

          value = arr[start2];
          index = start2;

          while (index != l) {
            arr[index] = arr[index - 1];
            index -= 1;
          }

          arr[l] = value;

          l++;
          m++;
          start2++;
        }
     }
     return arr;
    }
}