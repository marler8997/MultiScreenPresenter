
set GTKD_REPO=..\GtkD

dmd -ofmsp msp.d -L+%GTKD_REPO%\gtkd.lib -I%GTKD_REPO%\src
