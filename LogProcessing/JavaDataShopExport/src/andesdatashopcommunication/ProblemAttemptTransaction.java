/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package andesdatashopcommunication;

import java.io.Serializable;
import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.JoinColumn;
import javax.persistence.Lob;
import javax.persistence.ManyToOne;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.Table;

/**
 *
 * @author master
 */
@Entity
@Table(name = "PROBLEM_ATTEMPT_TRANSACTION")
@NamedQueries({@NamedQuery(name = "ProblemAttemptTransaction.findAll", query = "SELECT p FROM ProblemAttemptTransaction p"), @NamedQuery(name = "ProblemAttemptTransaction.findByTID", query = "SELECT p FROM ProblemAttemptTransaction p WHERE p.problemAttemptTransactionPK.tID = :tID"), @NamedQuery(name = "ProblemAttemptTransaction.findByClientID", query = "SELECT p FROM ProblemAttemptTransaction p WHERE p.problemAttemptTransactionPK.clientID = :clientID"), @NamedQuery(name = "ProblemAttemptTransaction.findByInitiatingParty", query = "SELECT p FROM ProblemAttemptTransaction p WHERE p.initiatingParty = :initiatingParty")})
public class ProblemAttemptTransaction implements Serializable {
    private static final long serialVersionUID = 1L;
    @EmbeddedId
    protected ProblemAttemptTransactionPK problemAttemptTransactionPK;
    @Lob
    @Column(name = "command")
    private String command;
    @Basic(optional = false)
    @Column(name = "initiatingParty")
    private String initiatingParty;
    @JoinColumn(name = "clientID", referencedColumnName = "clientID", insertable = false, updatable = false)
    @ManyToOne(optional = false)
    private ProblemAttempt problemAttempt;

    public ProblemAttemptTransaction() {
    }

    public ProblemAttemptTransaction(ProblemAttemptTransactionPK problemAttemptTransactionPK) {
        this.problemAttemptTransactionPK = problemAttemptTransactionPK;
    }

    public ProblemAttemptTransaction(ProblemAttemptTransactionPK problemAttemptTransactionPK, String initiatingParty) {
        this.problemAttemptTransactionPK = problemAttemptTransactionPK;
        this.initiatingParty = initiatingParty;
    }

    public ProblemAttemptTransaction(int tID, String clientID) {
        this.problemAttemptTransactionPK = new ProblemAttemptTransactionPK(tID, clientID);
    }

    public ProblemAttemptTransactionPK getProblemAttemptTransactionPK() {
        return problemAttemptTransactionPK;
    }

    public void setProblemAttemptTransactionPK(ProblemAttemptTransactionPK problemAttemptTransactionPK) {
        this.problemAttemptTransactionPK = problemAttemptTransactionPK;
    }

    public String getCommand() {
        return command;
    }

    public void setCommand(String command) {
        this.command = command;
    }

    public String getInitiatingParty() {
        return initiatingParty;
    }

    public void setInitiatingParty(String initiatingParty) {
        this.initiatingParty = initiatingParty;
    }

    public ProblemAttempt getProblemAttempt() {
        return problemAttempt;
    }

    public void setProblemAttempt(ProblemAttempt problemAttempt) {
        this.problemAttempt = problemAttempt;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (problemAttemptTransactionPK != null ? problemAttemptTransactionPK.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof ProblemAttemptTransaction)) {
            return false;
        }
        ProblemAttemptTransaction other = (ProblemAttemptTransaction) object;
        if ((this.problemAttemptTransactionPK == null && other.problemAttemptTransactionPK != null) || (this.problemAttemptTransactionPK != null && !this.problemAttemptTransactionPK.equals(other.problemAttemptTransactionPK))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "andesdatashopcommunication.ProblemAttemptTransaction[problemAttemptTransactionPK=" + problemAttemptTransactionPK + "]";
    }

}
