# -*- coding: utf-8 -*-
import numpy as np
cimport numpy as np
from pydbm.activation.interface.activating_function_interface import ActivatingFunctionInterface
ctypedef np.float64_t DOUBLE_t


class LogisticFunction(ActivatingFunctionInterface):
    '''
    Logistic Function.
    '''

    # Range of x.
    __overflow_range = 708.0

    # The length of memories.
    __memory_len = 50

    def __init__(self, memory_len=50):
        '''
        Init.
        '''
        self.__activity_arr_list = []
        self.__memory_len = memory_len

    def activate(self, np.ndarray x):
        '''
        Return of result from this activation function.

        Args:
            x   Parameter.

        Returns:
            The result.
        '''
        cdef double x_max
        cdef double x_min
        cdef double c_max
        cdef double c_min
        cdef double partition

        try:
            x_max = x.max()
            x_min = x.min()
            if x_max != x_min:
                x = (x - x.min()) / (x.max() - x.min())
        except FloatingPointError:
            pass

        c = x.max()
        cdef np.ndarray c_arr = np.nansum(
            np.array([
                np.expand_dims(-x, axis=0), 
                np.expand_dims(np.ones_like(x) * c, axis=0)
            ]),
            axis=0
        )[0]
        if c_arr[c_arr >= self.__overflow_range].shape[0] > 0 or c_arr[c_arr < -self.__overflow_range].shape[0] > 0:
            c_max = c_arr.max()
            c_min = c_arr.min()
            if c_max != c_min:
                c_arr = np.nansum(
                    np.array([
                        np.expand_dims(c_arr, axis=0),
                        np.expand_dims(np.ones_like(c_arr) * c_min * -1, axis=0)
                    ]),
                    axis=0
                )[0]
                partition = np.nansum(np.array([c_max, -1 * c_min]))
                c_arr = np.nanprod(
                    np.array([
                        np.expand_dims(c_arr, axis=0),
                        np.expand_dims(np.ones_like(c_arr) / partition, axis=0)
                    ]),
                    axis=0
                )[0]

                c_arr = np.nanprod(
                    np.array([
                        np.expand_dims(c_arr, axis=0),
                        np.expand_dims(
                            np.ones_like(c_arr) * (self.__overflow_range - (-self.__overflow_range)),
                            axis=0
                        )
                    ]),
                    axis=0
                )[0]
                c_arr = np.nansum(
                    np.array([
                        np.expand_dims(c_arr, axis=0),
                        np.expand_dims(np.ones_like(c_arr) * -self.__overflow_range, axis=0)
                    ]),
                    axis=0
                )[0]

        activity_arr = 1.0 / (1.0 + np.exp(c_arr))
        activity_arr = np.nan_to_num(activity_arr)

        x_max = activity_arr.max()
        x_min = activity_arr.min()
        if x_max != x_min:
            activity_arr = np.nansum(
                np.array([
                    np.expand_dims(activity_arr, axis=0),
                    np.expand_dims(np.ones_like(activity_arr) * x_min * -1, axis=0)
                ]),
                axis=0
            )[0]
            partition = np.nansum(np.array([x_max, -1 * x_min]))
            activity_arr = np.nanprod(
                np.array([
                    np.expand_dims(activity_arr, axis=0),
                    np.expand_dims(np.ones_like(activity_arr) / partition, axis=0)
                ]),
                axis=0
            )[0]

        self.__activity_arr_list.append(activity_arr)
        if len(self.__activity_arr_list) > self.__memory_len:
            self.__activity_arr_list = self.__activity_arr_list[len(self.__activity_arr_list) - self.__memory_len:]
        return activity_arr

    def derivative(self, np.ndarray y):
        '''
        Return of derivative result from this activation function.

        Args:
            y:   The result of activation.

        Returns:
            The result.
        '''
        activity_arr = self.__activity_arr_list.pop(-1)
        return y * (activity_arr * (1 - activity_arr))
