/** Definitions related to the Apache Commons Lang 2 library. */

import java
private import semmle.code.java.dataflow.ExternalFlow

private class ApacheStrBuilderModel extends SummaryModelCsv {
  override predicate row(string row) {
    row =
      [
        "org.apache.commons.text;StrBuilder;false;StrBuilder;(java.lang.String);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;append;(char[]);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;append;(char[],int,int);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;append;(java.lang.CharSequence);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;append;(java.lang.CharSequence,int,int);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;append;(java.lang.Object);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;append;(java.lang.String);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;append;(java.lang.String,int,int);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;append;(java.lang.String,java.lang.Object[]);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;append;(java.lang.String,java.lang.Object[]);;ArrayElement of Argument[1];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;append;(java.lang.StringBuffer);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;append;(java.lang.StringBuffer,int,int);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;append;(java.lang.StringBuilder);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;append;(java.lang.StringBuilder,int,int);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;append;(java.nio.CharBuffer);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;append;(java.nio.CharBuffer,int,int);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;append;(org.apache.commons.text.StrBuilder);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;append;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrBuilder;false;appendAll;(Iterable);;Element of Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;appendAll;(Iterator);;Element of Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;appendAll;(Object[]);;ArrayElement of Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;appendAll;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrBuilder;false;appendFixedWidthPadLeft;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrBuilder;false;appendFixedWidthPadLeft;;;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;appendFixedWidthPadRight;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrBuilder;false;appendFixedWidthPadRight;;;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;appendSeparator;(java.lang.String);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;appendSeparator;(java.lang.String,int);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;appendSeparator;(java.lang.String,java.lang.String);;Argument[0..1];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;appendSeparator;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrBuilder;false;appendTo;;;Argument[-1];Argument[0];taint",
        "org.apache.commons.text;StrBuilder;false;appendWithSeparators;(Iterable,String);;Element of Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;appendWithSeparators;(Iterator,String);;Element of Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;appendWithSeparators;(Object[],String);;ArrayElement of Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;appendWithSeparators;;;Argument[1];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;appendWithSeparators;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrBuilder;false;appendln;(char[]);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;appendln;(char[],int,int);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;appendln;(java.lang.Object);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;appendln;(java.lang.String);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;appendln;(java.lang.String,int,int);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;appendln;(java.lang.String,java.lang.Object[]);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;appendln;(java.lang.String,java.lang.Object[]);;ArrayElement of Argument[1];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;appendln;(java.lang.StringBuffer);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;appendln;(java.lang.StringBuffer,int,int);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;appendln;(java.lang.StringBuilder);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;appendln;(java.lang.StringBuilder,int,int);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;appendln;(org.apache.commons.text.StrBuilder);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;appendln;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrBuilder;false;asReader;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrBuilder;false;asTokenizer;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrBuilder;false;build;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrBuilder;false;getChars;(char[]);;Argument[-1];Argument[0];taint",
        "org.apache.commons.text;StrBuilder;false;getChars;(char[]);;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrBuilder;false;getChars;(int,int,char[],int);;Argument[-1];Argument[2];taint",
        "org.apache.commons.text;StrBuilder;false;insert;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrBuilder;false;insert;;;Argument[1];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;leftString;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrBuilder;false;midString;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrBuilder;false;readFrom;;;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;replace;(int,int,java.lang.String);;Argument[2];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;replace;(org.apache.commons.text.StrMatcher,java.lang.String,int,int,int);;Argument[1];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;replace;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrBuilder;false;replaceAll;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrBuilder;false;replaceAll;;;Argument[1];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;replaceFirst;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrBuilder;false;replaceFirst;;;Argument[1];Argument[-1];taint",
        "org.apache.commons.text;StrBuilder;false;rightString;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrBuilder;false;subSequence;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrBuilder;false;substring;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrBuilder;false;toCharArray;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrBuilder;false;toString;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrBuilder;false;toStringBuffer;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrBuilder;false;toStringBuilder;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;TextStringBuilder;false;TextStringBuilder;(java.lang.String);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;TextStringBuilder;(java.lang.CharSequence);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;append;(char[]);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;append;(char[],int,int);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;append;(java.lang.CharSequence);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;append;(java.lang.CharSequence,int,int);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;append;(java.lang.Object);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;append;(java.lang.String);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;append;(java.lang.String,int,int);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;append;(java.lang.String,java.lang.Object[]);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;append;(java.lang.String,java.lang.Object[]);;ArrayElement of Argument[1];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;append;(java.lang.StringBuffer);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;append;(java.lang.StringBuffer,int,int);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;append;(java.lang.StringBuilder);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;append;(java.lang.StringBuilder,int,int);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;append;(java.nio.CharBuffer);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;append;(java.nio.CharBuffer,int,int);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;append;(org.apache.commons.text.TextStringBuilder);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;append;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;TextStringBuilder;false;appendAll;(Iterable);;Element of Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;appendAll;(Iterator);;Element of Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;appendAll;(Object[]);;ArrayElement of Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;appendAll;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;TextStringBuilder;false;appendFixedWidthPadLeft;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;TextStringBuilder;false;appendFixedWidthPadLeft;;;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;appendFixedWidthPadRight;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;TextStringBuilder;false;appendFixedWidthPadRight;;;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;appendSeparator;(java.lang.String);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;appendSeparator;(java.lang.String,int);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;appendSeparator;(java.lang.String,java.lang.String);;Argument[0..1];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;appendSeparator;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;TextStringBuilder;false;appendTo;;;Argument[-1];Argument[0];taint",
        "org.apache.commons.text;TextStringBuilder;false;appendWithSeparators;(Iterable,String);;Element of Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;appendWithSeparators;(Iterator,String);;Element of Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;appendWithSeparators;(Object[],String);;ArrayElement of Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;appendWithSeparators;;;Argument[1];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;appendWithSeparators;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;TextStringBuilder;false;appendln;(char[]);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;appendln;(char[],int,int);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;appendln;(java.lang.Object);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;appendln;(java.lang.String);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;appendln;(java.lang.String,int,int);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;appendln;(java.lang.String,java.lang.Object[]);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;appendln;(java.lang.String,java.lang.Object[]);;ArrayElement of Argument[1];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;appendln;(java.lang.StringBuffer);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;appendln;(java.lang.StringBuffer,int,int);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;appendln;(java.lang.StringBuilder);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;appendln;(java.lang.StringBuilder,int,int);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;appendln;(org.apache.commons.text.TextStringBuilder);;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;appendln;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;TextStringBuilder;false;asReader;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;TextStringBuilder;false;asTokenizer;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;TextStringBuilder;false;build;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;TextStringBuilder;false;getChars;(char[]);;Argument[-1];Argument[0];taint",
        "org.apache.commons.text;TextStringBuilder;false;getChars;(char[]);;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;TextStringBuilder;false;getChars;(int,int,char[],int);;Argument[-1];Argument[2];taint",
        "org.apache.commons.text;TextStringBuilder;false;insert;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;TextStringBuilder;false;insert;;;Argument[1];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;leftString;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;TextStringBuilder;false;midString;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;TextStringBuilder;false;readFrom;;;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;replace;(int,int,java.lang.String);;Argument[2];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;replace;(org.apache.commons.text.matcher.StringMatcher,java.lang.String,int,int,int);;Argument[1];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;replace;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;TextStringBuilder;false;replaceAll;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;TextStringBuilder;false;replaceAll;;;Argument[1];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;replaceFirst;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;TextStringBuilder;false;replaceFirst;;;Argument[1];Argument[-1];taint",
        "org.apache.commons.text;TextStringBuilder;false;rightString;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;TextStringBuilder;false;subSequence;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;TextStringBuilder;false;substring;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;TextStringBuilder;false;toCharArray;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;TextStringBuilder;false;toString;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;TextStringBuilder;false;toStringBuffer;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;TextStringBuilder;false;toStringBuilder;;;Argument[-1];ReturnValue;taint"
      ]
  }
}

private class ApacheStrBuilderFluentMethodsModel extends SummaryModelCsv {
  override predicate row(string row) {
    row =
      [
        "org.apache.commons.text;StrBuilder;false;append;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;StrBuilder;false;appendAll;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;StrBuilder;false;appendFixedWidthPadLeft;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;StrBuilder;false;appendFixedWidthPadRight;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;StrBuilder;false;appendln;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;StrBuilder;false;appendNewLine;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;StrBuilder;false;appendNull;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;StrBuilder;false;appendPadding;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;StrBuilder;false;appendSeparator;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;StrBuilder;false;appendWithSeparators;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;StrBuilder;false;delete;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;StrBuilder;false;deleteAll;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;StrBuilder;false;deleteCharAt;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;StrBuilder;false;deleteFirst;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;StrBuilder;false;ensureCapacity;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;StrBuilder;false;insert;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;StrBuilder;false;minimizeCapacity;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;StrBuilder;false;replace;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;StrBuilder;false;replaceAll;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;StrBuilder;false;replaceFirst;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;StrBuilder;false;reverse;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;StrBuilder;false;setCharAt;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;StrBuilder;false;setLength;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;StrBuilder;false;setNewLineText;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;StrBuilder;false;setNullText;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;StrBuilder;false;trim;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;append;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;appendAll;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;appendFixedWidthPadLeft;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;appendFixedWidthPadRight;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;appendln;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;appendNewLine;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;appendNull;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;appendPadding;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;appendSeparator;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;appendWithSeparators;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;delete;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;deleteAll;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;deleteCharAt;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;deleteFirst;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;ensureCapacity;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;insert;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;minimizeCapacity;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;replace;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;replaceAll;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;replaceFirst;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;reverse;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;setCharAt;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;setLength;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;setNewLineText;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;setNullText;;;Argument[-1];ReturnValue;value",
        "org.apache.commons.text;TextStringBuilder;false;trim;;;Argument[-1];ReturnValue;value"
      ]
  }
}

/**
 * Taint-propagating models for `WordUtils`.
 */
private class ApacheWordUtilsModel extends SummaryModelCsv {
  override predicate row(string row) {
    row =
      [
        "org.apache.commons.text;WordUtils;false;wrap;;;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;WordUtils;false;wrap;(java.lang.String,int,java.lang.String,boolean);;Argument[2];ReturnValue;taint",
        "org.apache.commons.text;WordUtils;false;wrap;(java.lang.String,int,java.lang.String,boolean,java.lang.String);;Argument[2];ReturnValue;taint",
        "org.apache.commons.text;WordUtils;false;uncapitalize;(java.lang.String);;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;WordUtils;false;uncapitalize;(java.lang.String,char[]);;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;WordUtils;false;swapCase;;;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;WordUtils;false;capitalize;(java.lang.String);;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;WordUtils;false;capitalize;(java.lang.String,char[]);;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;WordUtils;false;abbreviate;;;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;WordUtils;false;abbreviate;;;Argument[3];ReturnValue;taint",
        "org.apache.commons.text;WordUtils;false;initials;(java.lang.String);;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;WordUtils;false;initials;(java.lang.String,char[]);;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;WordUtils;false;capitalizeFully;(java.lang.String);;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;WordUtils;false;capitalizeFully;(java.lang.String,char[]);;Argument[0];ReturnValue;taint"
      ]
  }
}

/**
 * Taint-propagating models for `StrTokenizer`.
 */
private class ApacheStrTokenizerModel extends SummaryModelCsv {
  override predicate row(string row) {
    row =
      [
        "org.apache.commons.text;StrTokenizer;false;StrTokenizer;;;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrTokenizer;false;clone;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrTokenizer;false;toString;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrTokenizer;false;reset;;;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;StrTokenizer;false;reset;;;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StrTokenizer;false;next;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrTokenizer;false;getContent;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrTokenizer;false;previous;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrTokenizer;false;getTokenList;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrTokenizer;false;getTokenArray;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrTokenizer;false;previousToken;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrTokenizer;false;nextToken;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StrTokenizer;false;getTSVInstance;;;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;StrTokenizer;false;getCSVInstance;;;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;StringTokenizer;false;StringTokenizer;;;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StringTokenizer;false;clone;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StringTokenizer;false;toString;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StringTokenizer;false;reset;;;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;StringTokenizer;false;reset;;;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StringTokenizer;false;next;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StringTokenizer;false;getContent;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StringTokenizer;false;previous;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StringTokenizer;false;getTokenList;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StringTokenizer;false;getTokenArray;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StringTokenizer;false;previousToken;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StringTokenizer;false;nextToken;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StringTokenizer;false;getTSVInstance;;;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;StringTokenizer;false;getCSVInstance;;;Argument[0];ReturnValue;taint"
      ]
  }
}

/**
 * Taint-propagating models for `StrLookup`.
 */
private class ApacheStrLookupModel extends SummaryModelCsv {
  override predicate row(string row) {
    row =
      [
        "org.apache.commons.text.lookup;StringLookup;true;lookup;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text.lookup;StringLookupFactory;false;mapStringLookup;;;MapValue of Argument[0];ReturnValue;taint"
      ]
  }
}

/**
 * Taint-propagating models for `StrSubstitutor`.
 */
private class ApacheStrSubstitutorModel extends SummaryModelCsv {
  override predicate row(string row) {
    row =
      [
        "org.apache.commons.text;StringSubstitutor;false;StringSubstitutor;;;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StringSubstitutor;false;StringSubstitutor;;;MapValue of Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StringSubstitutor;false;replace;;;Argument[-1];ReturnValue;taint",
        "org.apache.commons.text;StringSubstitutor;false;replace;(java.lang.Object);;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;StringSubstitutor;false;replace;(char[]);;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;StringSubstitutor;false;replace;(char[],int,int);;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;StringSubstitutor;false;replace;(java.lang.CharSequence);;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;StringSubstitutor;false;replace;(java.lang.CharSequence,int,int);;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;StringSubstitutor;false;replace;(java.lang.String);;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;StringSubstitutor;false;replace;(java.lang.StringBuffer);;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;StringSubstitutor;false;replace;(java.lang.StringBuffer,int,int);;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;StringSubstitutor;false;replace;(java.lang.String,int,int);;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;StringSubstitutor;false;replace;(java.lang.Object,java.util.Map);;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;StringSubstitutor;false;replace;(java.lang.Object,java.util.Map);;MapValue of Argument[1];ReturnValue;taint",
        "org.apache.commons.text;StringSubstitutor;false;replace;(java.lang.Object,java.util.Map,java.lang.String,java.lang.String);;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;StringSubstitutor;false;replace;(java.lang.Object,java.util.Map,java.lang.String,java.lang.String);;MapValue of Argument[1];ReturnValue;taint",
        "org.apache.commons.text;StringSubstitutor;false;replace;(java.lang.Object,java.util.Properties);;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;StringSubstitutor;false;replace;(java.lang.Object,java.util.Properties);;MapValue of Argument[1];ReturnValue;taint",
        "org.apache.commons.text;StringSubstitutor;false;replace;(org.apache.commons.text.TextStringBuilder);;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;StringSubstitutor;false;replace;(org.apache.commons.text.TextStringBuilder,int,int);;Argument[0];ReturnValue;taint",
        "org.apache.commons.text;StringSubstitutor;false;setVariableResolver;;;Argument[0];Argument[-1];taint",
        "org.apache.commons.text;StringSubstitutor;false;replaceIn;(java.lang.StringBuffer);;Argument[-1];Argument[0];taint",
        "org.apache.commons.text;StringSubstitutor;false;replaceIn;(java.lang.StringBuffer,int,int);;Argument[-1];Argument[0];taint",
        "org.apache.commons.text;StringSubstitutor;false;replaceIn;(java.lang.StringBuilder);;Argument[-1];Argument[0];taint",
        "org.apache.commons.text;StringSubstitutor;false;replaceIn;(java.lang.StringBuilder,int,int);;Argument[-1];Argument[0];taint",
        "org.apache.commons.text;StringSubstitutor;false;replaceIn;(org.apache.commons.text.TextStringBuilder);;Argument[-1];Argument[0];taint",
        "org.apache.commons.text;StringSubstitutor;false;replaceIn;(org.apache.commons.text.TextStringBuilder,int,int);;Argument[-1];Argument[0];taint"
      ]
  }
}
