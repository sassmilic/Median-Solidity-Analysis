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
      uint256[] memory arr
    )
      external
      pure
      returns (uint256 median)
    {
      uint i = 0;
      uint j;
      while (i < arr.length) {
        j = i;
        while (j > 0 && arr[j - 1] > arr[j]) {
          (arr[j], arr[j - 1]) = (arr[j - 1], arr[j]);
          j--;
        }
        i++;
      }
      if (arr.length % 2 == 1) {
        median = arr[arr.length / 2];
      } else {
        uint m = arr.length / 2;
        median = (arr[m - 1] + arr[m]) / 2;
      }
    }
}