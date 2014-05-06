#include <Python.h>


PyObject *Err_Base;


static PyObject *pytracer_execute(PyObject *self, PyObject *args)
{
    PyObject *ret;

    /* Reads arguments */
    const char *binary, *databasepath;
    char **argv;
    size_t argv_len;
    PyObject *py_argv;
    if(!(PyArg_ParseTuple(args, "sO!s",
                          &binary,
                          &PyList_Type, &py_argv,
                          &databasepath)))
        return NULL;

    /* DEBUG */
    fprintf(stderr,
            "pytracer_execute(\n"
            "    binary=%s\n"
            "    argv=",
            binary);
    PyObject_Print(py_argv, stderr, 0);
    fprintf(stderr,
            "\n"
            "    databasepath=%s\n"
            "    )\n",
            databasepath);

    /* Converts argv from Python list to char[][] */
    {
        argv_len = PyList_Size(py_argv);
        size_t i;
        argv = malloc((argv_len + 1) * sizeof(char*));
        for(i = 0; i < argv_len; ++i)
        {
            PyObject *arg = PyList_GetItem(py_argv, i);
            if(PyUnicode_Check(arg))
            {
                PyObject *pyutf8 = PyUnicode_AsUTF8String(arg);
                argv[i] = strdup(PyString_AsString(pyutf8));
                /* Py_DECREF(pyutf8) */
            }
            else
                argv[i] = strdup(PyString_AsString(arg));
        }
        argv[argv_len] = NULL;
    }

    if(fork_and_trace(argv_len, argv, databasepath) == 0)
    {
        Py_INCREF(Py_None);
        ret = Py_None;
    }
    else
    {
        PyErr_SetString(Err_Base, "Error occurred");
        ret = NULL;
    }

    /* Deallocs argv */
    {
        size_t i;
        for(i = 0; i < argv_len; ++i)
            free(argv[i]);
        free(argv);
    }

    return ret;
}


static PyMethodDef methods[] = {
    {"execute", pytracer_execute, METH_VARARGS,
     "execute(binary, argv, databasepath)\n"
     "\n"
     "Runs the specified binary with the argument list argv under trace and "
     "writes\nthe captured events to SQLite3 database databasepath."},
};

PyMODINIT_FUNC init_pytracer(void)
{
    PyObject *mod;

    mod = Py_InitModule("reprozip._pytracer", methods);
    if(mod == NULL)
        return;

    Err_Base = PyErr_NewException("_pytracer.Error", NULL, NULL);
    Py_INCREF(Err_Base);
    PyModule_AddObject(mod, "Error", Err_Base);
}
