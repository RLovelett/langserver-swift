//
//  Command.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/2/16.
//
//

/// Represents a reference to a command.
///
/// Provides a title which will be used to represent a command in the UI. Commands are identitifed
/// using a string identifier and the protocol currently doesn't specify a set of well known
/// commands. So executing a command requires some tool extension code.
struct Command {

    /// Title of the command, like `save`.
    let title: String

    /// The identifier of the actual command handler.
    let command: String

    /// Arguments that the command handler should be invoked with.
    let arguments: [Any]?

}
