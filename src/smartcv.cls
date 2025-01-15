% SPDX-License-Identifier: 0BSD
% copy paste as needed
\ProvidesClass{smartcv}[smartcv class] % intentionally no version number

\LoadClass[11pt, letterpaper]{article} % font size, paper type
\usepackage[parfill]{parskip} % remove paragraph indent
\usepackage{array} % \bf \bfseries tabular cols
\usepackage{ifthen} % \ifthenelse

\usepackage{hyperref}
\hypersetup{
  colorlinks=true,
  linkcolor=blue,
  filecolor=magenta,
  urlcolor=blue,
}

\pagestyle{empty} % no page numbers

% whitespace definitions                              <<<< Adjust here
\def \namesize {\LARGE} % name size
\def \nameskip {\smallskip} % space after name
\def \addresssep {$\diamond$} % const
\def \addressskip {\smallskip} % space between two address lines
\def \rSectionlineskip {\smallskip} % space above horizontal line for
% each section
\def \rSectionskip {\smallskip} % space after heading section

\let \@name \relax % var
\let \@addressOne \relax % var
\let \@addressTwo \relax % var

\def \name    #1{ \def \@name {#1} }
\def \addrone #1{ \def \@addressOne {#1} }
\def \addrtwo #1{ \def \@addressTwo {#1} }

% \printaddress to style address line
\def \printaddress #1{
  \begingroup
  \def \\ {\addresssep\ }
  \centerline{#1}
  \endgroup
  \par
  \addressskip
}

% \printname to print name as page header
\def \printname {
  \begingroup
  \hfil{\MakeUppercase{\namesize\bf \@name}}\hfil
  \nameskip\break
  \endgroup
}

% \begin{document} adjustment to print name and 2 lines personal information
\let\ori@document=\document
\renewcommand{\document}{
  \ori@document  % document start
  \@ifundefined{@name} { \@latex@error
    {Variable '@name' is undefined.}
    {Use \ name{Name Surname}.}
  }{ \printname
  }
  \@ifundefined{@addressOne} { \@latex@error
    {Variable '@addressOne' is undefined.}
    {Use \ addrone{+phone \\ place}.}
  }{ \printaddress{\@addressOne}
  }
  \@ifundefined{@addressTwo} { \@latex@error
    {Variable '@addressTwo' is undefined.}
    {Use \ addrtwo{\href{link1}{descr1} \\ ..}.}
  }{ \printaddress{\@addressTwo}
  }
}

% rSection environment
\newenvironment{rSection}[1]{
  \rSectionskip
  \MakeUppercase{{\bf #1}} % section title
  \rSectionlineskip
  \hrule % horizontal line
  \begin{list}{}{ % list for each section item
      \setlength{\leftmargin}{0cm} % margin within section
    }
  \item[]
  }{
  \end{list}
}
