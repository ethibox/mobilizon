import gql from "graphql-tag";

export const MEMBER_FRAGMENT = gql`
  fragment MemberFragment on Member {
    id
    role
    parent {
      id
      preferredUsername
      domain
      name
      avatar {
        url
      }
    }
    actor {
      id
      preferredUsername
      domain
      name
      avatar {
        url
      }
    }
    insertedAt
  }
`;

export const INVITE_MEMBER = gql`
  mutation InviteMember($groupId: ID!, $targetActorUsername: String!) {
    inviteMember(groupId: $groupId, targetActorUsername: $targetActorUsername) {
      ...MemberFragment
    }
  }
  ${MEMBER_FRAGMENT}
`;

export const ACCEPT_INVITATION = gql`
  mutation AcceptInvitation($id: ID!) {
    acceptInvitation(id: $id) {
      ...MemberFragment
    }
  }
  ${MEMBER_FRAGMENT}
`;

export const REJECT_INVITATION = gql`
  mutation RejectInvitation($id: ID!) {
    rejectInvitation(id: $id) {
      id
    }
  }
`;

export const GROUP_MEMBERS = gql`
  query($name: String!, $roles: String, $page: Int, $limit: Int) {
    group(preferredUsername: $name) {
      id
      url
      name
      domain
      preferredUsername
      members(page: $page, limit: $limit, roles: $roles) {
        elements {
          id
          role
          actor {
            id
            name
            domain
            preferredUsername
            avatar {
              url
            }
          }
          insertedAt
        }
        total
      }
    }
  }
`;

export const REMOVE_MEMBER = gql`
  mutation RemoveMember($groupId: ID!, $memberId: ID!) {
    removeMember(groupId: $groupId, memberId: $memberId) {
      id
    }
  }
`;
